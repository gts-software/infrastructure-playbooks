import os
import yaml
import toposort

def get_domain(project):
    if project['mode'] == 'staging':
        return project['domains']['staging'][project['branch']]
    if project['mode'] == 'production':
        return project['domains']['production']
    raise ValueError('invalid mode')

def get_subdomain(project, subdomain):
    domain = get_domain(project)
    if subdomain == '@':
        return domain
    return '{0}.{1}'.format(subdomain, domain)

def get_project_codename(project):
    if project['mode'] == 'staging':
        return '{0}_{1}_staging_{2}'.format(project['group'], project['name'], project['branch'])
    if project['mode'] == 'production':
        return '{0}_{1}_production'.format(project['group'], project['name'])
    raise ValueError('invalid mode')

def get_service_codename(project, service):
    if project['mode'] == 'staging':
        return '{0}_{1}_staging_{2}_{3}'.format(project['group'], project['name'], project['branch'], service)
    if project['mode'] == 'production':
        return '{0}_{1}_production_{2}'.format(project['group'], project['name'], service)
    raise ValueError('invalid mode')

def helper_get_target(target, mode, branch):
    target_string = None
    if mode == 'staging':
        target_string = target['staging'][branch]
    elif mode == 'production':
        target_string = target['production']
    else:
        raise ValueError('invalid mode')
    target_parts = target_string.split('@')
    if len(target_parts) > 2:
        raise ValueError('invalid target string')
    if len(target_parts) == 2:
        target_parts = { 'user': target_parts[0], 'host': target_parts[1] }
    else:
        target_parts = { 'user': None, 'host': target_parts[0] }
    target_parts['host'] = target_parts['host'].split(':')
    if len(target_parts['host']) > 2:
        raise ValueError('invalid target string')
    if len(target_parts['host']) == 2:
        target_parts['port'] = int(target_parts['host'][1])
        target_parts['host'] = target_parts['host'][0]
    else:
        target_parts['port'] = None
        target_parts['host'] = target_parts['host'][0]
    return target_parts

def filter_get_target_host(target, mode, branch):
    return helper_get_target(target, mode, branch)['host']

def filter_get_target_port(target, mode, branch):
    return helper_get_target(target, mode, branch)['port']

def filter_get_target_user(target, mode, branch):
    return helper_get_target(target, mode, branch)['user']

def filter_get_network(project):
    return get_project_codename(project)

def filter_get_services(project):
    result = { }
    for service in project['services']:
        result[service] = set(project['services'][service].get('depends_on', []))
    result = toposort.toposort_flatten(result)
    return result

def filter_get_service_name(project, service):
    return get_service_codename(project, service)

def filter_get_service_image(project, service):
    image = project['services'][service]['image']
    if image.startswith('project:'):
        return project['images'][image[8:]]['repository'] + ':' + project['mode'] + '_' + project['branch'] + '_' + project['version']
    return image;

def filter_get_service_labels(project, service):
    result = {
        'project.mode':    project['mode'],
        'project.branch':  project['branch'],
        'project.group':   project['group'],
        'project.name':    project['name'],
        'project.service': service,
    }
    if project['services'][service]['image'].startswith('project:'):
        result['project.version'] = project['version']
    if service in project['expose']:
        def mapdomain(domain):
            if isinstance(domain, dict):
                if 'mode' not in domain or domain['mode'] == project['mode']:
                    domain = domain['domain']
                else:
                    domain = None
            if domain is None:
                return None
            if domain.endswith('.'):
                return domain[:-1]
            return get_subdomain(project, domain)
        for item in project['expose'][service]:
            if item['type'] == 'http':
                result['traefik.enable'] = 'true'
                result['traefik.backend'] = get_service_codename(project, service)
                if 'domains' in item:
                    result['traefik.frontend.rule'] = 'Host:' + ','.join( filter( lambda x: x is not None, map( mapdomain, item['domains'] ) ) )
                if 'rule' in item:
                    result['traefik.frontend.rule'] = item['rule']
                if 'priority' in item:
                    result['traefik.frontend.priority'] = str(item['priority'])
                result['traefik.port'] = str(item['port'])
                result['traefik.docker.network'] = 'core_gate'
    return result

def filter_get_service_env(project, service):
    result = { }
    if project['services'][service]['image'].startswith('project:'):
        result['PROJECT_MODE'] = project['mode']
        result['PROJECT_BRANCH'] = project['branch']
        result['PROJECT_GROUP'] = project['group']
        result['PROJECT_NAME'] = project['name']
    if 'environment' in project['services'][service]:
        for envKey in project['services'][service]['environment']:
            envVal = project['services'][service]['environment'][envKey]
            if isinstance(envVal, dict):
                if project['mode'] in envVal:
                    envVal = envVal[project['mode']]
                else:
                    envVal = None
            if isinstance(envVal, dict):
                if project['branch'] in envVal:
                    envVal = envVal[project['branch']]
                else:
                    envVal = None
            if envVal is not None:
                result[envKey] = envVal
    return result

def filter_get_service_volumes(project, service):
    def volumedef(volume) :
        result = '/data/'
        if volume['source'].startswith('project:'):
            result += get_project_codename(project) + '/' + volume['source'][8:]
        elif volume['source'].startswith('service:'):
            result += get_service_codename(project, service) + '/' + volume['source'][8:]
        else:
            raise ValueError('invalid source', volume['source'])
        result = os.path.normpath( result )
        result += ':' + os.path.normpath( volume['destination'] )
        if 'flags' in volume:
            result += ':' + volume['flags']
        return result
    return map(volumedef, project['services'][service]['volumes'] if 'volumes' in project['services'][service] else [])

def filter_get_service_networks(project, service):
    result = [ { 'name': get_project_codename(project), 'aliases': [ service ] } ]
    if service in project['expose']:
        for item in project['expose'][service]:
            if item['type'] == 'http':
                result.append({ 'name': 'core_gate' })
                break
    return result

def filter_get_service_exposed_ports(project, service):
    return project['services'][service]['exposed_ports'] if 'exposed_ports' in project['services'][service] else []

def filter_get_service_published_ports(project, service):
    result = [ ]
    if service in project['expose']:
        for item in project['expose'][service]:
            if item['type'] == 'tcp' or item['type'] == 'udp':
                pext = '' if item['type'] == 'tcp' else '/udp'
                cport = str(item['port'])
                hport = None
                if 'hostport' in item:
                    if project['mode'] == 'production' and 'production' in item['hostport']:
                        hport = str(item['hostport']['production'])
                    if project['mode'] == 'staging' and 'staging' in item['hostport']:
                        if project['branch'] in item['hostport']['staging']:
                            hport = str(item['hostport']['staging'][project['branch']])
                if hport is not None:
                    cport = cport.split('-')
                    hport = hport.split('-')
                    if len(cport) != len(hport) or len(cport) > 2:
                        raise ValueError('invalid port specification')
                    if len(cport) == 1:
                        result.append(hport[0] + ':' + cport[0] + pext)
                    else:
                        if (int(cport[1]) - int(cport[0])) != (int(hport[1]) - int(hport[0])):
                            raise ValueError('invalid port specification')
                        for i in range(0, int(cport[1]) - int(cport[0]) + 2):
                            result.append(str(int(hport[0]) + i) + ':' + str(int(cport[0]) + i) + pext)
    return result


def filter_get_service_capabilities(project, service):
    if 'capabilities' in project['services'][service]:
        return project['services'][service]['capabilities']
    return [ ]

def filter_get_service_state(project, service):
    result = False
    if 'active' in project['services'][service]:
        active = project['services'][service]['active']
        if isinstance(active, bool):
            result = active
        elif project['mode'] == 'production' and 'production' in active:
            result = active['production']
        elif project['mode'] == 'staging' and 'staging' in active:
            if isinstance(active['staging'], bool):
                result = active['staging']
            elif project['branch'] in active['staging']:
                result = active['staging'][project['branch']]
    return 'started' if result == True else 'absent'

def filter_get_images(project):
    return project['images'].keys()

def filter_get_image_path(project, image, source):
    context = project['images'][image]['context'] if 'context' in project['images'][image] else ''
    return os.path.normpath(source + '/' + context)

def filter_get_image_dockerfile(project, image, source):
    context = project['images'][image]['context'] if 'context' in project['images'][image] else ''
    dockerfile = project['images'][image]['dockerfile']
    return os.path.normpath(source + '/' + context + '/' + dockerfile)

def filter_get_image_repository(project, image):
    return project['images'][image]['repository']

def filter_get_image_tag(project, image):
    return project['mode'] + '_' + project['branch'] + '_' + project['version']

def filter_get_image_tag_latest(project, image):
    return project['mode'] + '_' + project['branch'] + '_' + 'latest'

def filter_get_image_buildargs(project, image):
    result = {
        'PROJECT_MODE':    project['mode'],
        'PROJECT_BRANCH':  project['branch'],
        'PROJECT_GROUP':   project['group'],
        'PROJECT_NAME':    project['name'],
    }
    return result

class FilterModule(object):
    ''' Ansible project jinja2 filters '''

    def filters(self):
        return {
            'project_get_target_host'             : filter_get_target_host,
            'project_get_target_port'             : filter_get_target_port,
            'project_get_target_user'             : filter_get_target_user,
            'project_get_network'                 : filter_get_network,
            'project_get_services'                : filter_get_services,
            'project_get_service_name'            : filter_get_service_name,
            'project_get_service_image'           : filter_get_service_image,
            'project_get_service_labels'          : filter_get_service_labels,
            'project_get_service_env'             : filter_get_service_env,
            'project_get_service_volumes'         : filter_get_service_volumes,
            'project_get_service_networks'        : filter_get_service_networks,
            'project_get_service_exposed_ports'   : filter_get_service_exposed_ports,
            'project_get_service_published_ports' : filter_get_service_published_ports,
            'project_get_service_capabilities'    : filter_get_service_capabilities,
            'project_get_service_state'           : filter_get_service_state,
            'project_get_images'                  : filter_get_images,
            'project_get_image_path'              : filter_get_image_path,
            'project_get_image_dockerfile'        : filter_get_image_dockerfile,
            'project_get_image_repository'        : filter_get_image_repository,
            'project_get_image_tag'               : filter_get_image_tag,
            'project_get_image_tag_latest'        : filter_get_image_tag_latest,
            'project_get_image_buildargs'         : filter_get_image_buildargs,
        }

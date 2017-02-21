import os
import yaml
import toposort

def get_domain(project):
    if project['mode'] == 'staging':
        return '{0}.{1}'.format(project['branch'], project['domains']['staging'])
    return project['domains'][project['mode']]

def get_subdomain(project, subdomain):
    domain = get_domain(project)
    if subdomain == '@':
        return domain
    return '{0}.{1}'.format(subdomain, domain)

def get_project_codename(project):
    if project['mode'] == 'production':
        return '{0}_{1}_{2}'.format(project['group'], project['name'], project['mode'])
    return '{0}_{1}_{2}_{3}'.format(project['group'], project['name'], project['mode'], project['branch'])

def get_service_codename(project, service):
    if project['mode'] == 'production':
        return '{0}_{1}_{2}_{3}'.format(project['group'], project['name'], project['mode'], service)
    return '{0}_{1}_{2}_{3}_{4}'.format(project['group'], project['name'], project['mode'], project['branch'], service)

def filter_get_target(target, mode):
    if isinstance(target, basestring):
        return target
    return target[mode]

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
        'project.version': project['version'],
        'project.group':   project['group'],
        'project.name':    project['name'],
        'project.service': service,
    }
    if service in project['expose']:
        for item in project['expose'][service]:
            if item['type'] == 'http':
                result['traefik.enable'] = 'true'
                result['traefik.backend'] = get_service_codename(project, service)
                result['traefik.frontend.rule'] = 'Host:' + ','.join( map( lambda subdomain : get_subdomain(project, subdomain), item['domains'] ) )
                result['traefik.port'] = str(item['port'])
                result['traefik.docker.network'] = 'core_gate'
    if service in project['backup']:
        def backupdef(id):
            result = { 'id': id }
            result.update(project['backup'][service][id])
            return result
        result['backup'] = yaml.safe_dump(map(backupdef , project['backup'][service].keys()), default_flow_style=True)
    return result

def filter_get_service_env(project, service):
    result = {
        'PROJECT_MODE':    project['mode'],
        'PROJECT_BRANCH':  project['branch'],
        'PROJECT_VERSION': project['version'],
        'PROJECT_GROUP':   project['group'],
        'PROJECT_NAME':    project['name'],
    }
    if 'environment' in project['services'][service]:
        for envKey in project['services'][service]['environment']:
            result[envKey] = project['services'][service]['environment'][envKey]
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
    if service in project['backup']:
        for item in project['backup'][service]:
            if item['type'] != 'mount':
                result.append({ 'name': 'core_backup' })
                break
    return result

def filter_get_service_published_ports(project, service):
    result = [ ]
    if service in project['expose']:
        for item in project['expose'][service]:
            if item['type'] == 'tcp':
                cport = str(item['port'])
                hport = cport
                if 'hostport' in item:
                    if project['mode'] == 'production' and 'production' in item['hostport']:
                        hport = str(item['hostport']['production'])
                    if project['mode'] == 'staging' and 'staging' in item['hostport']:
                        if project['branch'] in item['hostport']['staging']:
                            hport = str(item['hostport']['staging'][project['branch']])
                cport = cport.split('-')
                hport = hport.split('-')
                if len(cport) != len(hport) or len(cport) > 2:
                    raise ValueError('invalid port specification')
                if len(cport) == 1:
                    result.append(cport + ':' + hport)
                else:
                    for i in range(0, int(cport[1]) - int(cport[0]) + 2):
                        result.append(str(int(cport) + i) + ':' + str(int(hport) + i))
    return result


def filter_get_service_capabilities(project, service):
    if 'capabilities' in project['services'][service]:
        return project['services'][service]['capabilities']
    return [ ]

def filter_get_images(project):
    return project['images'].keys()

def filter_get_image_dockerfile(project, image, source):
    return os.path.normpath(source + '/' + project['images'][image]['dockerfile'])

def filter_get_image_repository(project, image):
    return project['images'][image]['repository']

def filter_get_image_tag(project, image):
    return project['mode'] + '_' + project['branch'] + '_' + project['version']

def filter_get_image_buildargs(project, image):
    result = {
        'PROJECT_MODE':    project['mode'],
        'PROJECT_BRANCH':  project['branch'],
        'PROJECT_VERSION': project['version'],
        'PROJECT_GROUP':   project['group'],
        'PROJECT_NAME':    project['name'],
    }
    return result

class FilterModule(object):
    ''' Ansible project jinja2 filters '''

    def filters(self):
        return {
            'project_get_target'                  : filter_get_target,
            'project_get_network'                 : filter_get_network,
            'project_get_services'                : filter_get_services,
            'project_get_service_name'            : filter_get_service_name,
            'project_get_service_image'           : filter_get_service_image,
            'project_get_service_labels'          : filter_get_service_labels,
            'project_get_service_env'             : filter_get_service_env,
            'project_get_service_volumes'         : filter_get_service_volumes,
            'project_get_service_networks'        : filter_get_service_networks,
            'project_get_service_published_ports' : filter_get_service_published_ports,
            'project_get_service_capabilities'    : filter_get_service_capabilities,
            'project_get_images'                  : filter_get_images,
            'project_get_image_dockerfile'        : filter_get_image_dockerfile,
            'project_get_image_repository'        : filter_get_image_repository,
            'project_get_image_tag'               : filter_get_image_tag,
            'project_get_image_buildargs'         : filter_get_image_buildargs,
        }

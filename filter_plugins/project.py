import os
import yaml
import toposort

def qualify_domain(subdomain, domain):
    if subdomain == '@':
        return domain;
    return '{0}.{1}'.format(subdomain, domain)

def project_get_target(target, mode):
    if isinstance(target, basestring):
        return target
    return target[mode]

def project_get_network(project):
    return '{0}_{1}_{2}_{3}'.format(project['group'], project['name'], project['mode'], project['branch'])

def project_get_domain(project):
    if project['mode'] == 'staging':
        return '{0}.{1}'.format(project['branch'], project['domains']['staging'])
    return project['domains'][project['mode']]

def project_get_services(project):
    result = { }
    for service in project['services']:
        result[service] = set(project['services'][service].get('depends_on', []))
    result = toposort.toposort_flatten(result)
    return result

def project_get_service_name(project, service):
    return '{0}_{1}_{2}_{3}_{4}'.format(project['group'], project['name'], project['mode'], project['branch'], service)

def project_get_service_image(project, service):
    image = project['services'][service]['image']
    if image.startswith('project:'):
        return project['images'][image[8:]]['repository'] + ':' + project['mode'] + '_' + project['branch'] + '_' + project['version']
    return image;

def project_get_service_labels(project, service):
    result = {
        'project.mode':    project['mode'],
        'project.branch':  project['branch'],
        'project.version': project['version'],
        'project.group':   project['group'],
        'project.name':    project['name'],
        'project.service': service,
    }
    if service in project['expose']:
        result['traefik.enable'] = 'true'
        result['traefik.backend'] = project_get_service_name(project, service)
        result['traefik.frontend.rule'] = 'Host:' + ','.join( map( lambda x : qualify_domain(x, project_get_domain(project)), project['expose'][service]['domains'] ) )
        result['traefik.port'] = str(project['expose'][service]['port'])
    if service in project['backup']:
        def backupdef(id):
            result = { 'id': id }
            result.update(project['backup'][service][id])
            return result
        result['backup'] = yaml.safe_dump(map(backupdef , project['backup'][service].keys()), default_flow_style=True)
    return result

def project_get_service_env(project, service):
    result = {
        'PROJECT_MODE':    project['mode'],
        'PROJECT_BRANCH':  project['branch'],
        'PROJECT_VERSION': project['version'],
        'PROJECT_GROUP':   project['group'],
        'PROJECT_NAME':    project['name'],
    }
    return result

def project_get_service_volumes(project, service):
    def volumedef(volume) :
        result = os.path.normpath( '/data/' + project_get_service_name(project, service) + '/' + volume['source'] )
        result += ':' + os.path.normpath( volume['destination'] )
        if 'flags' in volume:
            result += ':' + volume['flags']
        return result
    return map(volumedef, project['services'][service]['volumes'])

def project_get_service_networks(project, service):
    result = [ { 'name': project_get_network(project), 'aliases': [ service ] } ]
    if service in project['expose']:
        result.append({ 'name': 'core_gate' })
    if service in project['backup']:
        result.append({ 'name': 'core_backup' })
    return result

def project_get_images(project):
    return project['images'].keys()

def project_get_image_dockerfile(project, image, source):
    return os.path.normpath(source + '/' + project['images'][image]['dockerfile'])

def project_get_image_repository(project, image):
    return project['images'][image]['repository']

def project_get_image_tag(project, image):
    return project['mode'] + '_' + project['branch'] + '_' + project['version']

def project_get_image_buildargs(project, image):
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
            'project_get_target'           : project_get_target,
            'project_get_network'          : project_get_network,
            'project_get_services'         : project_get_services,
            'project_get_service_name'     : project_get_service_name,
            'project_get_service_image'    : project_get_service_image,
            'project_get_service_labels'   : project_get_service_labels,
            'project_get_service_env'      : project_get_service_env,
            'project_get_service_volumes'  : project_get_service_volumes,
            'project_get_service_networks' : project_get_service_networks,
            'project_get_images'           : project_get_images,
            'project_get_image_dockerfile' : project_get_image_dockerfile,
            'project_get_image_repository' : project_get_image_repository,
            'project_get_image_tag'        : project_get_image_tag,
            'project_get_image_buildargs'  : project_get_image_buildargs,
        }

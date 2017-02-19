import os
import yaml
import toposort

def qualify_domain(subdomain, domain):
    if subdomain == '@':
        return domain;
    return '{0}.{1}'.format(subdomain, domain)

def project_get_network(project):
    return '{0}_{1}_{2}_{3}'.format(project['group'], project['name'], project['mode'], project['branch'])

def project_get_domain(project):
    if project['mode'] == 'staging':
        return '{0}.{1}'.format(project['branch'], project['domains']['staging'])
    return project['domains']['production']

def project_get_services(project):
    result = { }
    for service in project['services']:
        result[service] = set(project['services'][service].get('depends_on', []))
    result = toposort.toposort_flatten(result)
    return result

def project_get_service_name(project, service):
    return '{0}_{1}_{2}_{3}_{4}'.format(project['group'], project['name'], project['mode'], project['branch'], service)

def project_get_service_image(project, service):
    image = project['services'][service]['image'].split(':', 1)
    if len(image) == 1:
        image.append(project['version'])
    return ':'.join(image);

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

def project_get_service_volumes(project, service, data_dir):
    def volumedef(volume) :
        result = os.path.normpath( data_dir + '/' + project_get_service_name(project, service) + '/' + volume['source'] )
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

class FilterModule(object):
    ''' Ansible project jinja2 filters '''

    def filters(self):
        return {
            'project_get_network'          : project_get_network,
            'project_get_services'         : project_get_services,
            'project_get_service_name'     : project_get_service_name,
            'project_get_service_image'    : project_get_service_image,
            'project_get_service_labels'   : project_get_service_labels,
            'project_get_service_volumes'  : project_get_service_volumes,
            'project_get_service_networks' : project_get_service_networks,
        }

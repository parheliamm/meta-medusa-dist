import os
import subprocess

def get_medusa_version():
    try:
        version = os.environ['MEDUSA_VERSION']
    except KeyError:
        version = '4.0.0.255'
    return version

def isFileContentChanged(filePath, newContent):
    if os.path.isfile(filePath):
        with open(filePath, 'rt') as file:
            existingContent = file.read()
            if existingContent == newContent:
                return False
    return True

if __name__ == '__main__':
    version = get_medusa_version()
    git_date_time = subprocess.check_output(['git', 'log', '-1', '--format=%cd', '--date=format:%Y-%m-%d-%H%M%S']).strip()
    git_hash_short = subprocess.check_output(['git', 'rev-parse', '--short=8', 'HEAD']).strip()
    git_hash = subprocess.check_output(['git', 'rev-parse', 'HEAD']).strip()
    git_status = '-DIRTY' if subprocess.check_output(['git', 'status', '--porcelain']) else ''

    content = ''

    with open(os.path.dirname(os.path.realpath(__file__)) + '/conf/distro/medusa.conftemplate', 'rt') as recipe_template:
        for line in recipe_template:
            line = line.replace('${MEDUSA_METADATA_VERSION}', version)
            line = line.replace('${MEDUSA_METADATA_GIT_DATE_TIME}', git_date_time)
            line = line.replace('${MEDUSA_METADATA_GIT_HASH_SHORT}', git_hash_short)
            line = line.replace('${MEDUSA_METADATA_GIT_HASH}', git_hash)
            line = line.replace('${MEDUSA_METADATA_GIT_STATUS}', git_status)
            content += line

    if isFileContentChanged(os.path.dirname(os.path.realpath(__file__)) + '/conf/distro/medusa.conf', content):
        with open(os.path.dirname(os.path.realpath(__file__)) + '/conf/distro/medusa.conf', 'wt') as recipe:
            recipe.write(content)

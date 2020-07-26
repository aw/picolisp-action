# Main required modules
core      = require '@actions/core'
exec      = require '@actions/exec'

releaseVersion  = 'v2' # stable release version (git tag)
pilPath         = 'https://software-lab.de'
defaultVersion  = '20.6'
defaultArch     = 'src64'
allowedVersions = [defaultVersion, '19.12', '19.6', '18.12', '18.6', '17.12', 'latest']
allowedArch     = [defaultArch, 'src']

init = () ->
  try
    # Set temporary variables (input)
    ver   = await core.getInput('version',      { required: false })
    arch  = await core.getInput('architecture', { required: false })

    # Set internal variables
    pilVersion      = if ver  in allowedVersions then ver             else defaultVersion
    pilArchitecture = if arch in allowedArch     then arch            else defaultArch
    pilTarball      = if pilVersion is 'latest'  then 'picoLisp.tgz'  else "picoLisp-#{pilVersion}.tgz"

    # Update Ubuntu and install dependencies
    await exec.exec('sudo', ['apt-get', 'update'])
    await exec.exec('sudo', ['apt-get', 'install', 'libc6-dev-i386', 'libc6-i386', 'linux-libc-dev', 'gcc-multilib'])

    # Download and extract PicoLisp
    await exec.exec('curl', ['--http1.1', '-o', 'picolisp.tgz', "#{pilPath}/#{pilTarball}"], { cwd: '/tmp'})
    await exec.exec('tar',  ['-xf', 'picolisp.tgz'],                            { cwd: '/tmp'})

    # Build PicoLisp 32-bit
    await exec.exec('make', null, { cwd: '/tmp/picoLisp/src'})

    # Build PicoLisp 64-bit
    await exec.exec('make', null, { cwd: '/tmp/picoLisp/src64'}) if pilArchitecture is 'src64'

    # Install PicoLisp globally
    await exec.exec('sudo', ['ln', '-s', '/tmp/picoLisp',                   '/usr/lib/picolisp'])
    await exec.exec('sudo', ['ln', '-s', '/usr/lib/picolisp/bin/picolisp',  '/usr/bin'])
    await exec.exec('sudo', ['ln', '-s', '/usr/lib/picolisp/bin/pil',       '/usr/bin'])
    await exec.exec('sudo', ['ln', '-s', '/tmp/picoLisp',                   '/usr/share/picolisp'])

    # Display the compiled version
    console.log "Built PicoLisp ver:"
    await exec.exec('pil',  ['-version', '-bye'])

    await return

  catch error
    core.setFailed error.message

init()

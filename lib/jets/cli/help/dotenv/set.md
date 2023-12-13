## Examples

An SSM Parameter name is conventionally used based on JETS_ENV and the Jets project in `config/jets/project.rb`. Example:

    ❯ jets dotenv:set NAME1=value1 NAME2=value2
    Will set the SSM vars for demo-dev

      /demo/dev/NAME1
      /demo/dev/NAME2

    Are you sure? (y/N) y
    Setting SSM vars for demo-dev
    SSM Parameter set: /demo/dev/NAME1
    SSM Parameter set: /demo/dev/NAME2

If the env var includes a / then the SSM parameter is assumed to be fully qualified, there is conventional name expansion, and it is used as it.

    ❯ jets dotenv:set /dev/NAME1=value1
    Will set the SSM vars for sinatra-dev

      /dev/NAME1

    Are you sure? (y/N) y
    Setting SSM vars for sinatra-dev
    SSM Parameter set: /dev/NAME1

Imports a generic Rack application into a Jets project and configures it for [Mega Mode](http://rubyonjets.com/docs/megamode/).

Note, generic rack projects will likely need some adjustments to take into account API Gateway stages and logging. For more info refer to [Mega Mode Considerations](http://rubyonjets.com//megamode-details/).

## Example

    jets import:rack http://github.com/tongueroo/jets-mega-rails.git

## More Examples

    jets import:rack tongueroo/jets-mega-rails # expands to github
    jets import:rack git@github.com:tongueroo/jets-mega-rails.git
    jets import:rack /path/to/folder/jets-mega-rails

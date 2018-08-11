module Jets::Commands::Markdown
  class Index
    def path
      "docs/reference.md"
    end

    def command_list
      Jets::Commands::Base.namespaced_commands.sort.map do |full_command|
        # Example: [jets deploy]({% link _reference/jets-deploy.md %})
        link = full_command.gsub(':','-')
        "* [jets #{full_command}]({% link _reference/#{link}.md %})"
      end.join("\n")
    end

    def doc
      <<-EOL
---
title: CLI Reference
---
{% include reference.md %}

#{command_list}
EOL
    end
  end
end

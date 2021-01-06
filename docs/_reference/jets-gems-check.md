---
title: jets gems:check
reference: true
---

## Usage

    jets gems:check

## Description

Check if pre-built Lambda gems are available from the gems source. You can configure the gem in config/application.rb:

    # Sources for check for pre-compiled Lambda gems. Checks the list in order.
    Jets.application.configure do
      config.gems.source = "https://api.serverlessgems.com/api/v1"
    end

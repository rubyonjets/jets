---
title: jets gems:check
reference: true
---

## Usage

    jets gems:check

## Description

Check if pre-built Lambda gems are available from the sources.

You can configure additional gem sources in config/application.rb:

    # Sources for check for pre-compiled Lambda gems. Checks the list in order.
    Jets.application.configure do
      config.gems.sources = [
        "https://gems2.lambdagems.com"
      ]
    end



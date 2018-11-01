---
title: jets gems:check
reference: true
---

## Usage

    jets gems:check

## Description

Check if pre-built Lambda gems are available from the sources.

You can configure additional gem sources in config/application.rb:

    Jets.application.configure do
      config.lambdagems.sources = [
        "https://gems.lambdagems.com"
      ]
    end



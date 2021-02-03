# vision-server

[![Build Status](https://travis-ci.com/vision-it/vision-server.svg?branch=production)](https://travis-ci.com/vision-it/vision-server)

## Parameter

## Usage

Include in the *Puppetfile*:

```
mod 'vision_server',
    :git => 'https://github.com/vision-it/vision-server.git,
    :ref => 'production'
```

Include in a role/profile:

```puppet
contain ::vision_server
```


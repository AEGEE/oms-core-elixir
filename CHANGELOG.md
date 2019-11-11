## [0.3.2](https://github.com/AEGEE/oms-docker/compare/0.3.1...0.3.2) (2019-11-11)


### Bug Fixes

* **bodies:** fixed deprecation warning in route ([1f89907](https://github.com/AEGEE/oms-docker/commit/1f89907))
* **general:** allow passing multiple filter values ([f8b30f0](https://github.com/AEGEE/oms-docker/commit/f8b30f0))
* **test:** added tests for filters as arrays ([4ba0048](https://github.com/AEGEE/oms-docker/commit/4ba0048))



## [0.3.1](https://github.com/AEGEE/oms-docker/compare/0.3.0...0.3.1) (2019-11-08)


### Bug Fixes

* **docker:** fixed docker tag generation in docker-compose ([1490708](https://github.com/AEGEE/oms-docker/commit/1490708))


### Features

* **general:** switched to CircleCI from Travis. Fixes MEMB-678 ([4f41c87](https://github.com/AEGEE/oms-docker/commit/4f41c87))



# [0.3.0](https://github.com/AEGEE/oms-docker/compare/0.2.0...0.3.0) (2019-10-29)


### Bug Fixes

* **healthcheck:** add port number, and curl ([57f741d](https://github.com/AEGEE/oms-docker/commit/57f741d))
* deps.get does some magic, idk ([985f3ab](https://github.com/AEGEE/oms-docker/commit/985f3ab))
* forgot to update name of environment ([5c060df](https://github.com/AEGEE/oms-docker/commit/5c060df))
* **CI:** add .dev compose file to the CI ([cc329a8](https://github.com/AEGEE/oms-docker/commit/cc329a8))
* **CI:** env variables not set ([02f50f1](https://github.com/AEGEE/oms-docker/commit/02f50f1))
* **CI:** need a docker command ([e06b581](https://github.com/AEGEE/oms-docker/commit/e06b581))
* **CI:** the proper CMD breaks CI and I don't care ([c390fb3](https://github.com/AEGEE/oms-docker/commit/c390fb3))
* **docker:** avoid overwriting of folder ([f50d7a3](https://github.com/AEGEE/oms-docker/commit/f50d7a3))
* **docker:** do not ignore files we need to COPY ([3205790](https://github.com/AEGEE/oms-docker/commit/3205790))
* have to go around secrets ([d0b790f](https://github.com/AEGEE/oms-docker/commit/d0b790f))


### Features

* **bodies:** allow unauthorized access for /bodies and /bodies/:id. Fixes MEMB-680 ([2652f68](https://github.com/AEGEE/oms-docker/commit/2652f68))



# [0.2.0](https://github.com/AEGEE/oms-docker/compare/e9c9e43...0.2.0) (2019-08-29)


### Features

* **general:** added conventional commits and changelog. Fixes MEMB-588 ([98bba99](https://github.com/AEGEE/oms-docker/commit/98bba99))
* **general:** Healthcheck endpoint ([e9c9e43](https://github.com/AEGEE/oms-docker/commit/e9c9e43))




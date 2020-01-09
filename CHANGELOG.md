## [0.3.3](https://github.com/AEGEE/oms-docker/compare/0.3.2...0.3.3) (2020-01-05)


### Bug Fixes

* **users:** preload users on /permissions/:id/members ([282fd6a](https://github.com/AEGEE/oms-docker/commit/282fd6a74ecf314950c82a3a6c602fbf28a68c55))



## [0.3.2](https://github.com/AEGEE/oms-docker/compare/0.3.1...0.3.2) (2019-11-11)


### Bug Fixes

* **bodies:** fixed deprecation warning in route ([1f89907](https://github.com/AEGEE/oms-docker/commit/1f89907303d7d236309e65a26b9ea5db69aa4922))
* **general:** allow passing multiple filter values ([f8b30f0](https://github.com/AEGEE/oms-docker/commit/f8b30f070dcf19fb2e536bc502a937cdfefe4550))
* **test:** added tests for filters as arrays ([4ba0048](https://github.com/AEGEE/oms-docker/commit/4ba00481cf902d5bcde40248ed9bba60d8f4e703))



## [0.3.1](https://github.com/AEGEE/oms-docker/compare/0.3.0...0.3.1) (2019-11-08)


### Bug Fixes

* **docker:** fixed docker tag generation in docker-compose ([1490708](https://github.com/AEGEE/oms-docker/commit/14907082e94bfc574b4a74352cb142e552ad624e))


### Features

* **general:** switched to CircleCI from Travis. Fixes MEMB-678 ([4f41c87](https://github.com/AEGEE/oms-docker/commit/4f41c870c912e91dfe01206616c688b3cc5b9345))



# [0.3.0](https://github.com/AEGEE/oms-docker/compare/0.2.0...0.3.0) (2019-10-29)


### Bug Fixes

* **healthcheck:** add port number, and curl ([57f741d](https://github.com/AEGEE/oms-docker/commit/57f741d1e022016568c33482bfa46f3c0887bd64))
* deps.get does some magic, idk ([985f3ab](https://github.com/AEGEE/oms-docker/commit/985f3abc5d1f46765736d929f2700e4359b28145))
* forgot to update name of environment ([5c060df](https://github.com/AEGEE/oms-docker/commit/5c060dfcc6e49f5a66e4c382dd5dcb86c39450aa))
* **CI:** add .dev compose file to the CI ([cc329a8](https://github.com/AEGEE/oms-docker/commit/cc329a8c8f9198d35803fcdb04281133d04ca04e))
* **CI:** env variables not set ([02f50f1](https://github.com/AEGEE/oms-docker/commit/02f50f1085ab29a6d424d9e6463cf04bce647a4d))
* **CI:** need a docker command ([e06b581](https://github.com/AEGEE/oms-docker/commit/e06b5811c7092edce4fab1d046baace8e45c194f))
* **CI:** the proper CMD breaks CI and I don't care ([c390fb3](https://github.com/AEGEE/oms-docker/commit/c390fb3d71f6318f13fb61b20c7166e2338c4203))
* **docker:** avoid overwriting of folder ([f50d7a3](https://github.com/AEGEE/oms-docker/commit/f50d7a3c2ebe166c7d06d6dde8e65350bed93fcd))
* **docker:** do not ignore files we need to COPY ([3205790](https://github.com/AEGEE/oms-docker/commit/32057906ea8a26a1cdf250bfe47596c3530cd194))
* have to go around secrets ([d0b790f](https://github.com/AEGEE/oms-docker/commit/d0b790f4642e9f04d334e4922fd1ee97453f7d37))


### Features

* **bodies:** allow unauthorized access for /bodies and /bodies/:id. Fixes MEMB-680 ([2652f68](https://github.com/AEGEE/oms-docker/commit/2652f68172f0c793285f3341ab625f6aeea185f8))



# [0.2.0](https://github.com/AEGEE/oms-docker/compare/e9c9e43b0b0f575c1fa8962fb31a582a0ae46729...0.2.0) (2019-08-29)


### Features

* **general:** added conventional commits and changelog. Fixes MEMB-588 ([98bba99](https://github.com/AEGEE/oms-docker/commit/98bba99f3ea2e0cc0fbc7a30fe80622bf0038eee))
* **general:** Healthcheck endpoint ([e9c9e43](https://github.com/AEGEE/oms-docker/commit/e9c9e43b0b0f575c1fa8962fb31a582a0ae46729))




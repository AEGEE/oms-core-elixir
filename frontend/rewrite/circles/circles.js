(function ()
{
  'use strict';

  const baseUrl = baseUrlRepository['oms-core-elixir'];
  const apiUrl = `${baseUrl}api`;

  angular
  .module('app.circles', [])
  .config(config)
  .directive('simplecircle', SimpleCircleDirective)
  .directive('listcircles', ListCirclesDirective)
  .directive('listcirclememberships', ListCircleMembershipsDirective)
  .controller('CirclesController', CirclesController)
  .controller('SingleCircleController', SingleCircleController)
  .controller('ListCirclesController', ListCirclesController)
  .controller('ListCircleMembershipsController', ListCircleMembershipsController);

  /** @ngInject */
  function config($stateProvider)
  {
    // State
    $stateProvider
    .state('app.circles', {
      url: '/circles',
      data: {'pageTitle': 'Circles'},
      views   : {
        'pageContent@app': {
          templateUrl: baseUrl + 'rewrite/circles/circles.html',
          controller: 'CirclesController as vm'
        }
      }
    })
    .state('app.circles.single', {
      url: '/:id',
      data: {'pageTitle': 'Circle'},
      views   : {
        'pageContent@app': {
          templateUrl: baseUrl + 'rewrite/circles/single_circle.html',
          controller: 'SingleCircleController as vm'
        }
      }
    });
  }

  function SimpleCircleDirective() {
    return {
      restrict: 'E',
      scope: {
        circle: '='
      },
      templateUrl: baseUrl + 'rewrite/circles/directive_circle_simple.html'
    };
  }

  function ListCirclesDirective() {
    return {
      restrict: 'E',
      scope: {
        url: '=url',
        all: '=all'
      },
      templateUrl: baseUrl + 'rewrite/circles/directive_circle_list.html',
      controller: 'ListCirclesController as vm'
    }
  }

  function ListCircleMembershipsDirective() {
    return {
      restrict: 'E',
      scope: {
        url: '=url' // The url from which circle_memberships will be fetched
      },
      templateUrl: baseUrl + 'rewrite/circles/directive_circle_membership_list.html',
      controller: 'ListCircleMembershipsController as vm'
    }
  }

  function ListCirclesController($http, $scope) {

    // Data
    var vm = this;
    vm.query = "";

    vm.injectParams = (params) => {
      params.query = vm.query;
      params.all = $scope.all;
      return params;
    }
    infiniteScroll($http, vm, apiUrl + $scope.url, vm.injectParams);

    $scope.$watch('all', (newValue, oldValue) => {
      vm.resetData();
    }, true);
  }

  function CirclesController($http, $scope) {
    var vm = this;
    vm.baseUrl = baseUrl;

    vm.createCircle = () => {
      vm.edited_circle = {};
      $('#editCircleModal').modal('show');
    }

    vm.saveCircleForm = () => {
      $http({
        url: apiUrl + '/circles',
        method: 'POST',
        data: {circle: vm.edited_circle}
      }).then((response) => {
        showSuccess("Circle successfully created")
        $('#editCircleModal').modal('hide');
        // TODO reload circles list somehow...
      }).catch((error) => {
        if(error.status == 422)
          vm.errors = error.data.errors;
        else
          showError(error);
      });
    }
  }

  function SingleCircleController($http, $stateParams, $state, $scope) {
    var vm = this;
    vm.membersUrl = '/circles/' + $stateParams.id + '/members';
    vm.baseUrl = baseUrl;

    vm.loadCircle = () => {
      $http({
        url: apiUrl + '/circles/' + $stateParams.id,
        method: 'GET'
      }).then((response) => {
        vm.circle = response.data.data;
      }).catch((error) => {
        showError(error);
      });
    }
    vm.loadCircle();

    vm.loadInheritedPermissions = () => {
      $http({
        url: apiUrl + '/circles/' + $stateParams.id + '/permissions',
        method: 'GET'
      }).then((response) => {
        vm.inherited_permissions = response.data.data;
      }).catch((error) => {
        showError(error);
      })
    }
    vm.loadInheritedPermissions();

    vm.joinCircle = () => {
      vm.showMembers=false;
      $http({
        url: apiUrl + '/circles/' + $stateParams.id + '/members',
        method: 'POST'
      }).then((response) => {
        showSuccess("Joined circle");
      }).catch((error) => {
        showError(error);
      });
    }

    vm.deleteCircle = () => {
      $http({
        url: apiUrl + '/circles/' + $stateParams.id,
        method: 'DELETE'
      }).then((response) => {
        showSuccess("Successfully deleted circle");
        $state.go("app.circles");
      }).catch((error) => {
        showError(error);
      });
    }

    vm.editCircle = () => {
      vm.edited_circle = vm.circle;
      $('#editCircleModal').modal('show');
    }

    vm.saveCircleForm = () => {
      console.log(vm.edited_circle)
      $http({
        url: apiUrl + '/circles/' + $stateParams.id,
        method: 'PUT',
        data: {circle: vm.edited_circle}
      }).then((response) => {
        showSuccess("Circle successfully updated");
        $('#editCircleModal').modal('hide');
        vm.circle = response.data.data;
      }).catch((error) => {
        if(error.status == 422)
          vm.errors = error.data.errors;
        else
          showError(error);
      });
    }

    vm.updatePermissions = (permissions) => {
      $http({
        url: apiUrl + '/circles/' + $stateParams.id + '/permissions',
        method: 'PUT',
        data: {permissions: permissions}
      }).then((res) => {
        showSuccess("Permissions successfully updated");
        vm.circle = res.data.data;
        vm.loadInheritedPermissions();
      }).catch((error) => {
        showError(error);
      })
    }

    vm.deletePermission = (permission) => {
      let permissions = vm.circle.permissions.filter((x) => {return x.id != permission.id})
      vm.updatePermissions(permissions);
    }

    vm.addPermission = ($item) => {
      if($item) {
        let permissions = vm.circle.permissions.concat([$item.originalObject])
        vm.updatePermissions(permissions);
        $scope.$broadcast('angucomplete-alt:clearInput', 'editPermissionsTypeahead');
      }
    }

    vm.fetchPermissions = (query, timeout) => {
      return $http({
        url: apiUrl + '/permissions',
        method: 'GET',
        params: {
          limit: 8,
          offset: 0,
          query: query
        },
        transformResponse: appendHttpResponseTransform($http.defaults.transformResponse, function (res) {
          if(res && res.data) {
            return res.data;
          } else {
            return [];
          }
        }),
        timeout: timeout,
      });
    }

    vm.setParentCircle = ($item) => {
      if($item) {
        $http({
          url: apiUrl + '/circles/' + $stateParams.id + '/parent',
          method: 'PUT',
          data: {parent_circle_id: $item.originalObject.id}
        }).then((res) => {
          showSuccess("Parent circle modified successfully");
          vm.circle = res.data.data;
          vm.loadInheritedPermissions();
          $scope.$broadcast('angucomplete-alt:clearInput', 'parentCircleTypeahead');
        }).catch((error) => {
          showError(error);
        })
      }
    }

    vm.fetchCircles = function(query, timeout) {
      return $http({
        url: apiUrl + '/circles',
        method: 'GET',
        params: {
          limit: 8,
          offset: 0,
          query: query,
          all: true
        },
        transformResponse: appendHttpResponseTransform($http.defaults.transformResponse, function (res) {
          if(res && res.data) {
            return res.data;
          } else {
            return [];
          }
        }),
        timeout: timeout,
      });
    }


  }

  function ListCircleMembershipsController($http, $scope) {
    var vm = this;

    vm.loadMembers = () => {
      $http({
        url: apiUrl + $scope.url,
        method: 'GET'
      }).then((response) => {
        vm.circle_members = response.data.data;
      }).catch((error) => {
        showError(error);
      })
    }
    vm.loadMembers();

    vm.deleteMembership = (circle_membership) => {
      $http({
        url: apiUrl + "/circles/" + circle_membership.circle_id + "/members/" + circle_membership.id,
        method: 'DELETE'
      }).then((response) => {
        showSuccess("Membership deleted successfully");
        vm.loadMembers();
      }).catch((error) => {
        showError(error);
      })
    }

    vm.editMembership = (circle_membership) => {
      vm.edited_cm = circle_membership;
      $('#editCMModal').modal('show');
    }

    vm.saveForm = () => {
      $http({
        url: apiUrl + "/circles/" + vm.edited_cm.circle_id + "/members/" + vm.edited_cm.id,
        method: 'PUT',
        data: {circle_membership: vm.edited_cm}
      }).then((response) => {
        showSuccess("Membership updated successfully");
        vm.loadMembers();
        $('#editCMModal').modal('hide');
      }).catch((error) => {
        if(err.status == 422)
          vm.errors = err.data;
        else
          showError(err);
      })
    }
  }

})();
(function ()
{
    'use strict';

    const baseUrl = baseUrlRepository['oms-core-elixir'];
    const apiUrl = `${baseUrl}api`;

    angular
        .module('app.permissions', [])
        .config(config)
        .controller('CorePermissionsController', CorePermissionsController)
        .controller('CoreSinglePermissionController', CoreSinglePermissionController)

    /** @ngInject */
    function config($stateProvider)
    {
        // State
         $stateProvider
            .state('app.permissions', {
                url: '/permissions',
                data: {'pageTitle': 'Permissions'},
                views   : {
                    'pageContent@app': {
                        templateUrl: baseUrl + 'rewrite/permissions/permissions.html',
                        controller: 'CorePermissionsController as vm'
                    }
                }
            })
            .state('app.permissions.single', {
                url: '/{id}',
                data: {'pageTitle': 'Permissions'},
                views   : {
                    'pageContent@app': {
                        templateUrl: baseUrl + 'rewrite/permissions/single_permission.html',
                        controller: 'CoreSinglePermissionController as vm'
                    }
                }
            });
    }


    function CorePermissionsController($http) {
        var vm = this;
        vm.query = ""
        vm.baseUrl = baseUrl

        vm.injectParams = (params) => {
            params.query = vm.query
            return params;
        }
        infiniteScroll($http, vm, apiUrl + '/permissions', vm.injectParams, 20);

        vm.showEditModal = () => {
            $('#editPermissionModal').modal('show');
            vm.edited_permission = {filters: []};
        }

        vm.savePermissionForm = () => {
            $http({
                url: apiUrl + '/permissions',
                method: 'POST',
                data: {permission: vm.edited_permission}
            }).then((res) => {
                showSuccess("Permission created successfully");
                $('editPermissionModal').modal('hide');
                vm.resetData();
            }).catch((error) => {
                if(error.status == 422)
                    vm.errors = error.data.errors;
                else
                    showError(error);
            })
        }

    }

    function CoreSinglePermissionController($http, $stateParams, $state) {
        var vm = this;
        vm.baseUrl = baseUrl;

        vm.loadPermission = () => {
            $http({
                url: apiUrl + '/permissions/' + $stateParams.id,
                method: 'GET'
            }).then((res) => {
                vm.permission = res.data.data
            }).catch((error) => {
                showError(error);
            })
        }
        vm.loadPermission();

        vm.addFilter = (filter) => {
            vm.edited_permission.filters.push({field: filter})
        }

        vm.showEditModal = () => {
            $('#editPermissionModal').modal('show');
            vm.edited_permission = vm.permission;
        }

        vm.savePermissionForm = () => {
            $http({
                url: apiUrl + '/permissions/' + $stateParams.id,
                method: 'PUT',
                data: {permission: vm.edited_permission}
            }).then((res) => {
                showSuccess("Permission updated successfully");
                $('editPermissionModal').modal('hide');
                vm.permission = res.data.data;
            }).catch((error) => {
                if(error.status == 422)
                    vm.errors = error.data.errors;
                else
                    showError(error);
            })
        }

        vm.deletePermission = () => {
            $http({
                url: apiUrl + '/permissions/' + $stateParams.id,
                method: 'DELETE'
            }).then((res) => {
                showSuccess("Permission deleted successfully");
                $state.go("app.permissions");
            }).catch((error) => {
                showError(error);
            })
        }
    }

})();
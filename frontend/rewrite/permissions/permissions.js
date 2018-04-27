(function ()
{
    'use strict';

    const baseUrl = baseUrlRepository['oms-core-elixir'];
    const apiUrl = `${baseUrl}api`;

    angular
        .module('app.permissions', [])
        .config(config)
        .controller('CorePermissionsController', CorePermissionsController)

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
            });
    }


    function CorePermissionsController($http) {
        var vm = this;
        vm.query = ""

        vm.injectParams = (params) => {
            params.query = vm.query
            return params;
        }
        infiniteScroll($http, vm, apiUrl + '/permissions', vm.injectParams, 20);
    }

})();
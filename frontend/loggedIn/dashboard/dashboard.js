(function ()
{
    'use strict';

    const baseUrl = baseUrlRepository['oms-core-elixir'];
    const apiUrl = `${baseUrl}api`;

    angular
        .module('app.dashboard', [])
        .config(config)
        .controller('DashboardController', DashboardController);

    /** @ngInject */
    function config($stateProvider)
    {
        // State
         $stateProvider
            .state('app.dashboard', {
                url: '/dashboard',
                data: {'pageTitle': 'Dashboard'},
                views   : {
                    'pageContent@app': {
                        templateUrl: baseUrl + 'loggedIn/dashboard/dashboard.html',
                        controller: 'DashboardController as vm'
                    }
                }
            });
    }

    function DashboardController($http, $state) {
        // Data
        var vm = this;

    }

})();
(function ()
{
    'use strict';

    const baseUrl = baseUrlRepository['oms-core-elixir'];
    const apiUrl = `${baseUrl}api`;

    angular
        .module('app.members', [])
        .config(config)
        .directive('userpreview', UserPreviewDirective)
        .directive('omsSimpleUser', SimpleUserDirective)
        .controller('UserController', UserController);

    /** @ngInject */
    function config($stateProvider)
    {
        // State
         $stateProvider
            .state('app.members', {
                url: '/members',
                data: {'pageTitle': 'Members'},
                views   : {
                    'pageContent@app': {
                        templateUrl: baseUrl + 'loggedIn/users/users.html',
                        controller: 'UserController as vm'
                    }
                }
            });
    }

    function UserPreviewDirective() {
        return {
            restrict: 'E',
            scope: {
                user: '='
            },
            templateUrl: baseUrl + 'loggedIn/users/directive_userpreview.html'
        };
    }

    function SimpleUserDirective($http) {

        function link(scope, elements, attrs) {
            scope.message = "Fetching user";
            attrs.$observe('userid', function(value) {
                if(!value)
                    return;
                $http({
                    url: apiUrl + '/members/' + value,
                    method: 'GET'
                }).then(function(response) {
                    scope.fetched_user=response.data.data;
                    scope.message = "";
                }).catch(function(error) {
                    scope.message="Could not fetch"
                });
            })
        }

        return {
            templateUrl: baseUrl + 'loggedIn/users/directive_simple_user.html',
            restrict: 'E',
            scope: {
                userid: '@'
            },
            link: link,
        };
    }


    function UserController($http, $compile, $scope, $state) {
        // Data
        var vm = this;
        vm.query = "";


        vm.injectParams = (params) => {
            params.query = vm.query
            return params;
        }
        infiniteScroll($http, vm, apiUrl + '/members', vm.injectParams);
    }

})();
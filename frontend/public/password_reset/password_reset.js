(function ()
{
    'use strict';

    const baseUrl = baseUrlRepository['oms-core-elixir'];
    const apiUrl = `${baseUrl}api`;

    angular
        .module('public.password_reset', [])
        .config(config)
        .controller('CentralPasswordResetController', CentralPasswordResetController);

    /** @ngInject */
    function config($stateProvider)
    {
        // State
         $stateProvider
            .state('public.password_reset', {
                url: '/password_reset?token',
                params: {
                    token: null
                },
                data: {'pageTitle': 'Password forgotten'},
                views   : {
                    'main@': {
                        templateUrl: baseUrl + 'public/password_reset/password_reset.html',
                        controller: 'CentralPasswordResetController as vm'
                    }
                }
            });
    }

    function CentralPasswordResetController($stateParams, $http, $state) {
        var vm = this;
        if($stateParams.token) {
            vm.paramToken = true;
            vm.showTokenField = true;
            vm.token = $stateParams.token;
        }

        vm.sendResetRequest = () => {
            vm.errors = {};
            $http({
                url: apiUrl + '/password_reset',
                method: 'POST',
                data: {email: vm.email}
            }).then((res) => {
                showSuccess("You should receive a mail soon, please enter the token you were provided");
                vm.showTokenField = true;
            }).catch((error) => {
                if(error.status == 404)
                    vm.errors.email = "Email not found"
                else
                    showError(error);
            })
        }

        vm.confirmResetRequest = () => {
            vm.errors = {};
            if(vm.new_password != vm.new_password_copy) {
                vm.errors = {password: "Passwords don't match"};
                return;
            }

            $http({
                url: apiUrl + '/confirm_reset_password/' + vm.token,
                method: 'POST',
                data: {password: vm.new_password}
            }).then((res) => {
                showSuccess("Password changed successfully")
                $state.go("public.welcome")
            }).catch((error) => {
                switch(error.status) {
                    case 404: vm.errors = {token: "Invalid token"}; break;
                    case 422: vm.errors = error.data.errors; break;
                    default: showError(error);
                }
                
            })
        }
    }

})();
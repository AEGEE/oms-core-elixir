(function ()
{
    'use strict';

    const baseUrl = baseUrlRepository['oms-core-elixir'];
    const apiUrl = `${baseUrl}api`;


    angular
        .module('public.signup', [])
        .config(config)
        .controller('CentralSignupController', CentralSignupController)
        .controller('CentralConfirmSignupController', CentralConfirmSignupController);

    /** @ngInject */
    function config($stateProvider)
    {
        // State
         $stateProvider
            .state('public.signup', {
                url: '/signup/{campaign_id}',
                data: {'pageTitle': 'Signing up to OMS'},
                views   : {
                    'main@': {
                        templateUrl: baseUrl + 'public/signup/signup.html',
                        controller: 'CentralSignupController as vm'
                    }
                }
            })
            .state('public.confirm_signup', {
                url: '/confirm_signup?token?campaign_id',
                params: {
                    token: null,
                    campaign_id: null
                },
                data: {'pageTitle': 'Confirm your email by providing a token'},
                views   : {
                    'main@': {
                        templateUrl: baseUrl + 'public/signup/confirm.html',
                        controller: 'CentralConfirmSignupController as vm'
                    }
                }
            });
    }

    function CentralSignupController($http, $state, $stateParams) {
        var vm = this;
        vm.campaign_id = $stateParams.campaign_id

        vm.sendSignup = () => {
            vm.errors = {};

            if(vm.user.password != vm.user.password_copy) {
                vm.errors = {password: "Passwords don't match"}
                return;
            }
            if(!vm.terms) {
                vm.errors = {terms: "You must accept the terms and conditions to proceed"}
                return;
            }

            $http({
                url: apiUrl + '/campaigns/' + $stateParams.campaign_id,
                method: 'POST',
                data: {submission: vm.user}
            }).then((res) => {
                showSuccess("You should receive a token in your email inbox soon")
                $state.go("public.confirm_signup")
            }).catch((error) => {
                if(error.status == 422)
                    vm.errors = error.data.errors;
                else
                    showError(error)
            })
        }

    }

    function CentralConfirmSignupController($http, $stateParams, $state) {
        var vm = this;


        if($stateParams.token) {
            vm.token = $stateParams.token
        }

        if($stateParams.campaign_id)
            vm.campaign_id = $stateParams.campaign_id;

        vm.submitToken = () => {
            $http({
                url: apiUrl + '/confirm_mail/' + vm.token,
                method: 'POST'
            }).then((res) => {
                showSuccess("Congratulations, you can now login with your new username");
                $state.go("public.welcome");
            }).catch((error) => {
                showError(error);
            })
        }
    }

})();
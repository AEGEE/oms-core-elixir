(function ()
{
    'use strict';

    const baseUrl = baseUrlRepository['oms-core-elixir'];
    const apiUrl = `${baseUrl}api`;

    angular
        .module('app.profile', [])
        .config(config)
        .controller('ProfileController', ProfileController)

    /** @ngInject */
    function config($stateProvider)
    {
        // State
         $stateProvider
            .state('app.profile', {
                url: '/profile/{id}',
                data: {'pageTitle': 'Profile'},
                views   : {
                    'pageContent@app': {
                        templateUrl: baseUrl + 'loggedIn/profile/profile.html',
                        controller: 'ProfileController as vm'
                    }
                }
            });
    }


    function ProfileController($http, $stateParams, $state) {
        // Data
        var vm = this;
        vm.user = {};
        vm.permissions = {
            edit_profile: true
        };
        vm.baseUrl = baseUrl;
        
        // TODO check if own user, if yes display OwnProfileController
        vm.getUser = function() {
            $http({
                method: 'GET',
                url: apiUrl + '/members/' + $stateParams.id,
            })
            .then(function successCallback(response) {
                vm.user = response.data.data;
            }).catch(function(err) {showError(err);});
        }
        vm.getUser();


        vm.showEditProfileModal = function() {
            $('#editProfileModal').modal('show');
        }

        vm.saveProfile = function() {
            $http({
                method: 'PUT',
                url: apiUrl + '/members/' + vm.user.id,
                data: {member: vm.user}
            })
            .then(function successCallback(response) {
                // Successfully saved that body
                $('#editProfileModal').modal('hide');
                $.gritter.add({
                    title: 'Success',
                    text: `Successfully edited profile`,
                    sticky: false,
                    time: 8000,
                    class_name: 'my-sticky-class',
                  });
                vm.getUser();
            }).catch(function(err) {
                if(err.status == 422)
                    vm.errors = err.errors;
                else
                    showError(err);
            });
        }
    }

})();
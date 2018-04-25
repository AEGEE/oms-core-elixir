(function ()
{
    'use strict';

    const baseUrl = baseUrlRepository['oms-core-elixir'];
    const apiUrl = `${baseUrl}api`;
    const loginserviceUrl = baseUrlRepository['oms-loginservice'] + "api";

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


    function ProfileController(loginModal, $http, $stateParams, $state, $rootScope) {
        // Data
        var vm = this;
        vm.member = {};
        vm.permissions = {
            edit_profile: true,
            delete_profile: true
        };
        vm.ownProfile = false;
        vm.baseUrl = baseUrl;

        vm.changePicture = () => {
            showError("Come join the oms team to implement this feature")
        }
        
        // TODO check if own user, if yes display OwnProfileController
        vm.getMember = function() {
            $http({
                method: 'GET',
                url: apiUrl + '/members/' + $stateParams.id,
            })
            .then(function successCallback(response) {
                vm.member = response.data.data;
                vm.member.date_of_birth = new Date(vm.member.date_of_birth);
                vm.ownProfile = vm.member.id == $rootScope.currentUser.id;
                vm.getUser(); // Call this here so on missing permissions we get only one error
            }).catch(function(err) {showError(err);});
        }
        vm.getMember();

        vm.getUser = () => {
            $http({
                method: 'GET',
                url: loginserviceUrl + '/user/' + $stateParams.id,
            })
            .then(function successCallback(response) {
                vm.user = response.data.data;
            }).catch(function(err) {showError(err);});
        }
        

        vm.showEditProfileModal = function() {
            $('#editProfileModal').modal('show');
        }

        vm.saveProfile = function() {
            $http({
                method: 'PUT',
                url: apiUrl + '/members/' + $stateParams.id,
                data: {member: vm.member}
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
                vm.getMember();
            }).catch(function(err) {
                if(err.status == 422)
                    vm.errors = err.data.errors;
                else
                    showError(err);
            });
        }

        vm.fetchBodies = (query, timeout) => {
          return $http({
            url: apiUrl + '/bodies',
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

        vm.setPrimaryBody = ($item) => {
            if($item) {
                vm.member.primary_body_id = $item.originalObject.id;
                vm.member.primary_body = $item.originalObject;
            } else {
                vm.member.primary_body_id = null;
                vm.member.primary_body = undefined;
            }
        }


        vm.showEditUserDataModal = function() {
            $('#editUserDataModal').modal('show');
        }

        vm.saveUserData = function() {
            let data = {user: vm.user};
            if(vm.user.password) {
                if(vm.user.password_copy != vm.user.password){
                    vm.errors = {password: "Passwords not matching"}
                    return;
                }
                data.old_password = vm.user.old_password;
            }
            $http({
                method: 'PUT',
                url: loginserviceUrl + '/user',
                data: data
            })
            .then(function successCallback(response) {
                // Successfully saved that body
                $('#editUserDataModal').modal('hide');
                showSuccess("Successfully edited user information")
                authenticate(loginModal, $rootScope, $http, {skipCheckToken: true});
                vm.getUser();
            }).catch(function(err) {
                if(err.status == 422)
                    vm.errors = err.data.errors;
                else
                    showError(err);
            });
        }

        vm.deleteProfile = () => {
            $http({
                url: apiUrl + '/members/' + $stateParams.id,
                method: 'DELETE'
            }).then((res) => {
                showSuccess("Member deleted successfully. It might take some time until his login will be deactivated")
                $state.go("app.dashboard")
            }).catch((error) => {
                showError(error);
            })
        }
    }

})();
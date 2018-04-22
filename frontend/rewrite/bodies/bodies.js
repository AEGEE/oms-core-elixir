(function ()
{
    'use strict';

    const baseUrl = baseUrlRepository['oms-core-elixir'];
    const apiUrl = `${baseUrl}api`;

    angular
        .module('app.bodies', [])
        .config(config)
        .directive('bodytile', BodyTileDirective)
        .controller('BodyListingController', BodyListingController)
        .controller('BodySingleController', BodySingleController);

    /** @ngInject */
    function config($stateProvider)
    {
        // State
         $stateProvider
            .state('app.bodies', {
                url: '/bodies',
                data: {'pageTitle': 'All Bodies'},
                views   : {
                    'pageContent@app': {
                        templateUrl: baseUrl + 'rewrite/bodies/list.html',
                        controller: 'BodyListingController as vm'
                    }
                }
            })
            .state('app.bodies.single', {
                url: '/bodies/:id',
                data: {'pageTitle': 'Body Details'},
                views   : {
                    'pageContent@app': {
                        templateUrl: baseUrl + 'rewrite/bodies/single.html',
                        controller: 'BodySingleController as vm'
                    }
                }
            });
    }

    function BodyTileDirective() {
        return {
            restrict: 'E',
            scope: {
                body: '='
            },
            templateUrl: baseUrl + 'rewrite/bodies/directive_bodytile.html'
        };
    }

    function BodyListingController($http, $scope, $stateParams) {
        // Data
        var vm = this;
        vm.baseUrl = baseUrl;
        // TODO replace with real fetch from backend
        vm.permissions = {
            create_body: true
        };

        vm.query = "";
        
        vm.injectParams = (params) => {
            params.query = vm.query
            return params;
        }
        infiniteScroll($http, vm, apiUrl + '/bodies', vm.injectParams);


        vm.body = {};
        vm.body_types = [];
        vm.querytoken = 0;


        vm.saveBodyForm = function() {
            // Create the body
            $http({
                method: 'POST',
                url: apiUrl + '/bodies',
                data: {body: vm.body}
            })
            .then(function successCallback(response) {
                // Successfully saved that body
                $('#editBodyModal').modal('hide');
                showSuccess("Successfully added body");
                vm.resetData();
            }).catch(function(err) {
                if(err.status == 422)
                    vm.errors = err.data.errors;
                else
                    showError(err);
            });
        };

        vm.showBodyModal = function() {
            $('#editBodyModal').modal('show');
        }
    }

    function BodySingleController($http, $scope, $stateParams, $state) {
        var vm = this;
        vm.baseUrl = baseUrl;
        vm.permissions = {
            edit_body: true,
            edit_circles: true,
            request_join: true
        };
        vm.body = {};
        vm.countries = [];
        vm.body_types = [];

        vm.getBody = function(id) {
            $http({
                method: 'GET',
                url: apiUrl + '/bodies/' + id
            })
            .then(function successCallback(response) {
                vm.body = response.data.data;
            }).catch(function(err) {showError(err);});
        };
        vm.getBody($stateParams.id);

        vm.saveBodyForm = function() {
            $http({
                method: 'PUT',
                url: apiUrl + '/bodies/' + vm.body.id,
                data: {body: vm.body}
            })
            .then(function successCallback(response) {
                // Successfully saved that body
                $('#editBodyModal').modal('hide');
                showSuccess("Sucessfully updated body");
                vm.getBody($stateParams.id);
            }).catch(function(err) {
                if(err.status == 422)
                    vm.errors = err.data.errors;
                else
                    showError(err);
            });
        };

        vm.showBodyModal = function() {
            $('#editBodyModal').modal('show');
        }

        vm.deleteBody = () => {
            $http({
                url: apiUrl + '/bodies/' + vm.body.id,
                method: 'DELETE'
            }).then((res) => {
                showSuccess("Body and all bound circles were deleted successfully");
                $state.go("app.bodies");
            }).catch((error) => {
                showError(error);
            });
        }

        vm.createCircle = () => {
          vm.edited_circle = {};
          $('#editCircleModal').modal('show');
        }

        vm.saveCircleForm = () => {
          $http({
            url: apiUrl + '/bodies/' + $stateParams.id + '/circles',
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

        vm.loadMembers = () => {
            $http({
                url: apiUrl + '/bodies/' + $stateParams.id + '/members',
                method: 'GET'
            }).then((response) => {
                vm.body_members = response.data.data;
            }).catch((error) => {
                showError(error);
            });
        }

        vm.deleteMembership = (membership) => {
            $http({
                url: apiUrl + '/bodies/' + $stateParams.id + '/members/' + membership.id,
                method: 'DELETE'
            }).then((res) => {
                showSuccess("Member successfully deleted");
                vm.loadMembers();
            }).catch((error) => {
                showError(error);
            })
        }

        vm.loadJoinRequests = () => {
            $http({
                url: apiUrl + '/bodies/' + $stateParams.id + '/join_requests',
                method: 'GET'
            }).then((response) => {
                vm.join_requests = response.data.data;
            }).catch((error) => {
                showError(error);
            });
        }

        vm.processJoinRequest = (join_request, approved) => {
            $http({
                url: apiUrl + '/bodies/' + $stateParams.id + '/join_requests/' + join_request.id,
                method: 'POST',
                data: {approved: approved}
            }).then((res) => {
                showSuccess("Join request approved successfully");
                vm.loadJoinRequests();
                vm.loadMembers();
            }).catch((error) => {
                showError(error);
            });
        }

        vm.joinBody = () => {
            $('#joinRequestModal').modal('show');
        }

        vm.saveJoinRequestForm = (motivation) => {
            $http({
                url: apiUrl + '/bodies/' + $stateParams.id + '/members',
                method: 'POST',
                data: {join_request: {motivation: motivation}}
            }).then((res) => {
                showSuccess("Join request sent");
                $('#joinRequestModal').modal('hide');
            }).catch((error) => {
                if(error.status == 422)
                    vm.errors = error.data.errors;
                else
                    showError(error);
            })
        }
    }

})();
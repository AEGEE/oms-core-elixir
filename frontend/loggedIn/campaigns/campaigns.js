(function ()
{
    'use strict';

    const baseUrl = baseUrlRepository['oms-core-elixir'];
    const apiUrl = `${baseUrl}api`;

    angular
        .module('app.campaigns', [])
        .config(config)
        .controller('RecruitmentCampaignController', RecruitmentCampaignController)
        .controller('SingleRecruitmentCampaignController', SingleRecruitmentCampaignController);

    /** @ngInject */
    function config($stateProvider)
    {
        // State
         $stateProvider
            .state('app.campaigns', {
                url: '/campaigns',
                data: {'pageTitle': 'Recruitment Campaigns'},
                views   : {
                    'pageContent@app': {
                        templateUrl: baseUrl + 'loggedIn/campaigns/campaigns.html',
                        controller: 'RecruitmentCampaignController as vm'
                    }
                }
            })
            .state('app.campaigns.single', {
                url: '/{id}', 
                data: {'pageTitle': 'Single Recruitment Campaign'},
                views   : {
                    'pageContent@app': {
                        templateUrl: baseUrl + 'loggedIn/campaigns/single_campaign.html',
                        controller: 'SingleRecruitmentCampaignController as vm'
                    }
                }
            });
    }


    function RecruitmentCampaignController($http) {
        var vm = this;
        vm.query = "";
        vm.baseUrl = baseUrl;

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

        vm.showEditModal = () => {
            $('#editCampaignModal').modal('show');
            vm.edited_campaign = vm.campaign;
        }

        vm.assignBody = ($item) => {
            if($item) {
                vm.edited_campaign.autojoin_body = $item.originalObject;
                vm.edited_campaign.autojoin_body_id = vm.edited_campaign.autojoin_body.id;
            }
            else {
                vm.edited_campaign.autojoin_body = null;
                vm.edited_campaign.autojoin_body_id = null;
            }
        }

        vm.saveCampaignForm = () => {
            $http({
                url: apiUrl + '/backend_campaigns',
                method: 'POST',
                data: {campaign: vm.edited_campaign}
            }).then((res) => {
                showSuccess("Campaign updated successfully");
                vm.resetData();
                $('#editCampaignModal').modal('hide');
            }).catch((error) => {
                if(error.status == 422)
                    vm.errors = error.data.errors;
                else
                    showError(error);
            })
        }


        vm.injectParams = (params) => {
            params.query = vm.query
            return params;
        }
        infiniteScroll($http, vm, apiUrl + '/backend_campaigns', vm.injectParams);
    }

    function SingleRecruitmentCampaignController($http, $stateParams, $state) {
        var vm = this;
        vm.baseUrl = baseUrl;

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

        vm.loadCampaign = () => {
            $http({
                url: apiUrl + '/backend_campaigns/' + $stateParams.id,
                method: 'GET'
            }).then((res) => {
                vm.campaign = res.data.data
            }).catch((error) => {
                showError(error);
            })
        }
        vm.loadCampaign();

        vm.showEditModal = () => {
            $('#editCampaignModal').modal('show');
            vm.edited_campaign = vm.campaign;
        }

        vm.assignBody = ($item) => {
            if($item) {
                vm.edited_campaign.autojoin_body = $item.originalObject;
                vm.edited_campaign.autojoin_body_id = vm.edited_campaign.autojoin_body.id;
            }
            else {
                vm.edited_campaign.autojoin_body = null;
                vm.edited_campaign.autojoin_body_id = null;
            }
        }

        vm.saveCampaignForm = () => {
            $http({
                url: apiUrl + '/backend_campaigns/' + $stateParams.id,
                method: 'PUT',
                data: {campaign: vm.edited_campaign}
            }).then((res) => {
                showSuccess("Campaign updated successfully");
                vm.loadCampaign();
                $('#editCampaignModal').modal('hide');
            }).catch((error) => {
                if(error.status == 422)
                    vm.errors = error.data.errors;
                else
                    showError(error);
            })
        }

        vm.deleteCampaign = () => {
            $http({
                url: apiUrl + '/backend_campaigns/' + $stateParams.id,
                method: 'DELETE'
            }).then(() => {
                showSuccess("Campaign deleted successfully");
                $state.go("app.campaigns")
            }).catch((error) => {
                showError(error);
            })
        }
    }

})();
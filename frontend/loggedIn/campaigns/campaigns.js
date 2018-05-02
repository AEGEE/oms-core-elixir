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


        vm.injectParams = (params) => {
            params.query = vm.query
            return params;
        }
        infiniteScroll($http, vm, apiUrl + '/backend_campaigns', vm.injectParams);
    }

    function SingleRecruitmentCampaignController($http, $stateParams) {
        var vm = this;

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
    }

})();
# Views and things so user's can take action on the data

# TODO: generic mailto directive or handler for mailto click events

class TakeActionRoutes extends Config
    constructor: ($stateProvider, $urlRouterProvider) ->
        $urlRouterProvider
            .when('/ta', '/take-action')
            .when('/ta/:who', '/take-action/:who')

        $stateProvider
            .state('take_action',
                url: '/take-action'
                views:
                    'content':
                        templateUrl: 'take_action/landing.html'
                        controller: 'takeActionController'
                    'header':
                        template: 'Take Action'
            )
            .state('take_action.tell_the',
                url: '/tell/:who'
                views:
                    'content@':
                        templateUrl: (stateParams) ->
                            return "take_action/contact_#{stateParams.who}.html"
                        controller: 'takeActionController'
                    'header@':
                        templateProvider: ($stateParams, $filter) ->
                            who = $filter('ucfirst')($stateParams.who)
                            return "Tell the #{who}"
                    'action_area@take_action.tell_the':
                        templateUrl: 'take_action/action_button.html'
                        controller: ($scope, $stateParams) ->
                            # $scope.action_text = ''
                            $scope.who = $stateParams.who
            )
            .state('take_action.share',
                url: '/share'
                views:
                    'content@':
                        templateUrl: 'take_action/share.html'
                        controller: ($scope, $window) ->
                            $scope.data_url = 'fake_url'
                            $scope.title = 'fake_title& things'
                            $scope.send_email = ->
                                if @Email.$valid
                                    $window.location = """mailto:#{$scope.to_email}?subject=
                                    Someone wants you to know about this data&body=check it out! #{$scope.data_url}"""
                    'header@':
                        template: 'Share This Data'
                    'action_area@take_action.share':
                        templateUrl: 'take_action/action_button.html'
                        controller: ($scope, $stateParams) ->
                            $scope.action_text = 'Want to Tell us Something?'
                            $scope.who = $stateParams.who
            )

# class FeedbackForm extends Controller

class TakeAction extends Controller
    constructor: ($scope, $state, $stateParams) ->

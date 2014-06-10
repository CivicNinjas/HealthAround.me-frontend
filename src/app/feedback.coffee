# Handle feedback forms and such.
class FeedbackAPI extends Service
    constructor: ($http, API_CONFIG) ->
        @send_feedback = (data) ->
            $http.post("#{API_CONFIG.endpoint}/feedback", data)

class FeedbackRoutes extends Config
    constructor: ($stateProvider, $urlRouterProvider) ->
        $urlRouterProvider
            .when('/f', '/feedback')

        $stateProvider
            # Basic feedback form
            .state('feedback',
                url: '/feedback'
                views:
                    'content':
                        templateUrl: 'feedback.html'
                        controller: 'feedbackController'
                    'header':
                        template: 'Give us Feedback'
            )
            # Handle sending feedback related to a specific score
            .state('feedback.score',
                url: '/:detail/:action'
                views:
                    'content@':
                        templateUrl: 'feedback.html'
                        controller: 'feedbackController'
                    'header@':
                        template: 'Improve your Community'
            )
            .state('feedback.tell_about',
                url: '/who/:detail'
                view:
                    'content@':
                        templateUrl: 'feedback.html'
                        controller: 'feedbackController'
                    'header@':
                        template: 'Improve your Community'
            )
            # .state('feedback.thanks',
            #     url: '/thanks'
            #     views:
            #         '':
            #             template: 'thanks for the feedback?'
            # )

# class FeedbackForm extends Controller

class Feedback extends Controller
    constructor: ($log, $scope, $state, $stateParams, feedbackAPIService) ->
        $scope.feedback = {}
        # take params from state and insert them into the form request
        angular.extend($scope.feedback, $stateParams)

        $scope.submit_feedback = ->
            if @FeedbackForm.$valid
                feedbackAPIService.send_feedback($scope.feedback).then (ret, status) ->
                    # TODO: success/failure message
                    $log.log(ret, status)

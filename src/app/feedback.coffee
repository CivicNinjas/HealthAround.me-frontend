# Handle feedback forms and such.
class FeedbackAPI extends Service
    constructor: ($http) ->
        send_feedback: (data) ->
            $http.post
                data: data

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
                        controller: 'feedbackController'
                        templateUrl: 'feedback.html'
                    'header':
                        template: 'Give us Feedback'
            )
            # Handle sending feedback related to a specific score
            .state('feedback.score',
                url: '/:score_slug'
                views:
                    'content@':
                        controller: 'feedbackController'
                        templateUrl: 'feedback.html'
                    'header@':
                        template: 'Improve your Community'
            )
            .state('feedback.tell_about',
                url: '/who'
                view:
                    'content@':
                        controller: 'feedbackController'
                        templateUrl: 'feedback.html'
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
    constructor: ($scope, $state, $stateParams, feedbackAPIService) ->
        $scope.submit_feedback = =>
            if @FeedbackForm.$valid
                debugger

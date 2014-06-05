class ScoreRoutes extends Config
    constructor: ($stateProvider, $urlRouterProvider) ->
        $urlRouterProvider
            .when('/s/:lat/:lng/', '/score/:lat,:lng/')

        $stateProvider
            .state('score',
                url: '/score/:lat,:lng/'
                views:
                    '':
                        templateUrl: 'score.html'
                        controller: 'scoreStateController'
                    'header':
                        template: 'HealthAround.me Score'
                # sync score_data loading
                # resolve:
                #     score_data: ['scoreService', '$stateParams', (scores, $stateParams) ->
                #         return scores.byLatLng($stateParams)
                #     ]
            )
            .state('score.cards'
                url: 'cards/'
                views:
                    '':
                        templateUrl: 'cards/base.html'
                        controller: 'cardsController'
                    'header':
                        template: 'Cards'
            )

class Cards extends Controller
    constructor: ($scope, $state, $stateParams) ->


angular.module('ham').filter 'letter_score', ->
    (score) ->
        # only work with da numbars
        return score if not angular.isNumber(score)
        # take 0 - 1 and select a letter
        try
            ['F','F','D','D','C','C','B','B','A','A','A'][Math.floor(score * 10)]
        catch e
            return score


class Score extends Service
    constructor: ($http) ->
        @byLatLng = (coords) ->
            return $http.jsonp("http://api.healtharound.me/api/score/#{coords.lat},#{coords.lng}/?format=jsonp&callback=JSON_CALLBACK").then (resp) ->
                return resp.data


class ScoreState extends Controller
    constructor: ($scope, $state, $stateParams, scoreService, $filter) ->
        $scope.score_data = {}
        $scope.score = false

        # get score every time
        scoreService.byLatLng($stateParams).then (data) ->
            $scope.score_data = data

        # average score
        $scope.$watch 'score_data', (score_data) ->
            return if not score_data.elements?.length > 0
            total_score = 0
            for elm in score_data.elements
                total_score += elm.score
            $scope.score = total_score / score_data.elements.length
            # FUTURE implementation
            # $scope.score = score_data.score

        $scope.$watch 'score', (score) ->
            $scope.letter_score = $filter('letter_score')(parseFloat(score))

        $scope.go_to_interaction = (type) ->
            $state.go("score.#{type}", $stateParams)

class ScoreRoutes extends Config
    constructor: ($stateProvider, $urlRouterProvider) ->
        $urlRouterProvider
            .when('/s/:lat/:lng/', '/score/:lat,:lng/')

        $stateProvider
            .state('score',
                url: '/score/:lat,:lng/'
                views:
                    'content':
                        templateUrl: 'score.html'
                        controller: 'scoreStateController'
                    'header':
                        template: 'HealthAround.me Score'
                # sync score_data loading
                resolve:
                    score_data: ['scoreService', '$stateParams', (scores, $stateParams) ->
                        return scores.byLatLng($stateParams)
                    ]
            )
            .state('score.cards',
                url: 'cards/'
                views:
                    'content@':
                        templateUrl: 'cards/base.html'
                        controller: 'cardsController'
                    'header@':
                        template: 'Cards'
            )
            .state('score.detail',
                url: 'detail/:boundary_slug/:metric_slug/'
                views:
                    'content@':
                        templateUrl: 'score/detail.html'
                        controller: 'scoreDetailController'
                    'header@':
                        template: '{{detail.properties.metric.label}}'
                        controller: ['$scope', 'detail', ($scope, detail) ->
                            $scope.detail = detail
                        ]
                resolve:
                    detail: ['scoreService', '$stateParams', (scores, $stateParams) ->
                        return scores.detail($stateParams)
                    ]
            )

class Cards extends Controller
    constructor: ($scope, $state, $stateParams) ->


class Score extends Service
    constructor: ($http, API_CONFIG) ->
        @byLatLng = (coords) ->
            return $http.jsonp("#{API_CONFIG.endpoint}/score/#{coords.lat},#{coords.lng}/?format=jsonp&callback=JSON_CALLBACK").then (resp) ->
                return resp.data
        @detail = (params) ->
            return $http.jsonp("#{API_CONFIG.endpoint}/detail/#{params.boundary_slug}/#{params.metric_slug}/?format=jsonp&callback=JSON_CALLBACK").then (resp) ->
                return resp.data


class ScoreDetail extends Controller
    constructor: ($scope, detail, $state, $stateParams) ->
        $scope.metric = detail.properties.metric
        $scope.detail = detail
        centroid = detail.properties.centroid.coordinates
        $scope.center =
            lat: centroid[1]
            lng: centroid[0]
            zoom: 13


class ScoreState extends Controller
    constructor: ($scope, score_data, $state, $stateParams, scoreService, $filter) ->
        # average score
        $scope.score = score_data.score

        $scope.$watch 'score', (score) ->
            $scope.letter_score = $filter('letter_score')(parseFloat(score))

        $scope.go_to_interaction = (type) ->
            $state.go("score.#{type}", $stateParams)

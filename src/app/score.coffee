class ScoreRoutes extends Config
    constructor: ($stateProvider, $urlRouterProvider) ->
        $urlRouterProvider
            .when('/s/:lat/:lng/', '/score/:lat,:lng/')

        $stateProvider
            .state('score',
                url: '/score/:lat,:lng'
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
                url: '/cards'
                views:
                    'content@':
                        templateUrl: 'cards/base.html'
                        controller: 'cardsController'
                    'header@':
                        template: 'HealthAround.me Scores'
                    'cards@score.cards':
                        templateUrl: 'cards/group.html'
                        controller: 'cardGroupController'
            )
            .state('score.cards.nav',
                urls: '/:slugs'
                # future params
                # params:
                #     slugs:
                #         value: null
                views:
                    'cards@score.cards':
                        templateUrl: 'cards/group.html'
                        controller: 'cardGroupController'
            #         'header@':
            #             template: 'lzlzlz'
            )
            .state('score.detail',
                url: '/detail/:boundary_slug/:metric_slug/'
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


class CardGroup extends Controller
    constructor: ($scope, $state, score_data, $stateParams) ->
        # get first set of elements
        $scope.elements = score_data.elements
        $scope.top_element = $scope.elements[0]

        $scope.$watch 'elements', (top_elements) ->
            $scope.flattened_scores = []
            for top_element in top_elements
                for inner_element in top_element.elements
                    inner_element.parent = top_element
                    $scope.flattened_scores.push inner_element

        $scope.slide_index = 0
        $scope.$watch 'slide_index', (index) ->
            return if not angular.isNumber(index)
            $scope.active_element = $scope.flattened_scores[index]

        $scope.$watch 'active_element', (new_element, old_element) ->
            $scope.top_element = new_element.parent
            if old_element
                old_element.active = false
            if new_element
                new_element.active = true

        # set slide index to tapped element
        $scope.focus_on = (element) ->
            $scope.slide_index = $scope.flattened_scores.indexOf(element)


class Cards extends Controller
    constructor: ($scope, $state, score_data, $stateParams) ->


class Score extends Service
    constructor: ($http, API_CONFIG) ->
        @byLatLng = (coords) ->
            return $http.jsonp("#{API_CONFIG.endpoint}/score/#{coords.lat},#{coords.lng}/?format=jsonp&callback=JSON_CALLBACK").then (resp) ->
                return resp.data
        @detail = (params) ->
            return $http.jsonp("#{API_CONFIG.endpoint}/detail/#{params.boundary_slug}/#{params.metric_slug}/?format=jsonp&callback=JSON_CALLBACK").then (resp) ->
                return resp.data


class ScoreDetail extends Controller
    constructor: ($scope, detail, $state, $stateParams, leafletData) ->
        $scope.metric = detail.properties.metric
        $scope.geojson =
            data: detail
        centroid = detail.properties.centroid.coordinates
        $scope.center =
            lat: centroid[1]
            lng: centroid[0]
            zoom: 13

        leafletData.getMap('boundary-map').then (map) ->
            map.dragging.disable()
            map.touchZoom.disable()
            map.doubleClickZoom.disable()
            map.scrollWheelZoom.disable()
            map.boxZoom.disable()
            map.keyboard.disable()
        # # try at zoom map to bounds
        #     bounds = L.latLngBounds(detail.geometry.coordinates)
        #     map.fitBounds(bounds)


class ScoreState extends Controller
    constructor: ($scope, score_data, $state, $stateParams, scoreService, $filter) ->
        # average score
        $scope.score = score_data.score

        $scope.$watch 'score', (score) ->
            $scope.letter_score = $filter('letter_score')(parseFloat(score))

        $scope.go_to_interaction = (type) ->
            $state.go("score.#{type}", $stateParams)

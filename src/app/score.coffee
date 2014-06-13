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
                url: '/cards/{slugs:.*}'
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
    constructor: ($log, $scope, $state, score_data, $stateParams) ->
        # unaddultered list of elements
        $scope.elements = score_data.elements
        $scope.level_elements = []

        target_level = 0
        # find our data!
        if $stateParams.slugs and (slugs = $stateParams.slugs?.split('/')).length > 0
            found_element = null

            level = 0
            walker = (elements, level) ->
                for element in elements
                    if element.slug is slugs[level]
                        # find if we're at the last level and select element
                        if level + 1 == slugs.length
                            return [level, element]
                        if element.elements
                            level++
                            return walker(element.elements, level)
                return [1, false]

            [target_level, found_element] = walker(score_data.elements, level)

            if found_element
                $scope.top_element = found_element
                $scope.elements = found_element.elements



        $scope.flattened_scores = []
        $scope.$watch 'elements', (all_elements) ->
            $log.log('elements_changed', all_elements)
            # reset flattened_scores
            $scope.flattened_scores = []
            for top_element in all_elements
                if top_element.elements
                    for inner_element in top_element.elements
                        inner_element.active = false
                        $scope.flattened_scores.push inner_element
                else
                    top_element.active = false
                    $scope.flattened_scores.push top_element

        # when we drag the carousel of bars and let go we update the index
        # sets the new active element
        $scope.slide_index = 0
        $scope.$watch 'slide_index', (index) ->
            $log.log('slide_index', index)
            return if not angular.isNumber(index)
            $scope.active_element = $scope.flattened_scores[index]

        # When the active element changed unset the old active element
        $scope.$watch 'active_element', (new_element, old_element) ->
            $log.log('active_element', new_element, old_element)
            return if not new_element
            $scope.top_element = new_element.parent
            if old_element
                old_element.active = false
            if new_element
                new_element.active = true

        # set slide index to tapped element
        $scope.focus_on = (element) ->
            $scope.slide_index = $scope.flattened_scores.indexOf(element)

        # create the slug for
        $scope.nav_to = (element) ->
            # determine if going to detail view,
            # navigating element has no children
            return if not element
                $log.error 'no element to navigate to'
            if not element.elements?
                # element.parent.elements
                $state.go 'score.detail',
                    boundary_slug: element.boundary_id
                    metric_slug: element.slug
                return
            slugs = []
            find_slugs = (element) ->
                slugs.push(element.slug)
                if element.parent
                    find_slugs(element.parent)
            find_slugs(element)
            slug_tree = slugs.reverse().join('/')
            $log.log slug_tree
            $state.go 'score.cards',
                slugs: slug_tree


# bar-handler bar-swipe-up="nav_to(element)"
# angular.module('ham').directive 'barHandler', ($swipe, $parse) ->
#     restrict: 'A'
#     scope: true
#     compile: (tElement, tAttributes) ->
#         return (scope, iElement, iAttributes) ->
#             iAttributes.$observe 'swipe-up' (newvalue) ->
#                 debugger
#                 $swipe.bind()


class Cards extends Controller
    constructor: ($scope, $state, score_data, $stateParams) ->


class Score extends Service
    constructor: ($http, API_CONFIG, $cacheFactory) ->
        cache = $cacheFactory('score_data_loookup')
        @byLatLng = (coords) ->
            coord_key = (coord_axis) ->
                # 100meter - 43meter resolution for cache,
                # if you move only slightly you'll recieve the same data.
                parseFloat(coord_axis).toFixed(3).toString()
            key = coord_key(coords.lat)+coord_key(coords.lng)
            data = cache.get(key)
            return data if data
            return $http.jsonp("#{API_CONFIG.endpoint}/score/#{coords.lat},#{coords.lng}/?format=jsonp&callback=JSON_CALLBACK", cache: true).then (resp) ->
                walker = (element) ->
                    return if not element.elements
                    for child_element in element.elements
                        # attach parent object here so we can access it when we narrow down our di
                        child_element.parent = element if element.slug
                        child_element.active = false
                        walker(child_element)
                    return
                walker(resp.data)
                cache.put(key, resp.data);
                return resp.data

        @detail = (params) ->
            return $http.jsonp("#{API_CONFIG.endpoint}/detail/#{params.boundary_slug}/#{params.metric_slug}/?format=jsonp&callback=JSON_CALLBACK", cache: true).then (resp) ->
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

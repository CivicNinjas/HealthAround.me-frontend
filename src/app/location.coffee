class LocationRoutes extends Config
    constructor: ($stateProvider, $urlRouterProvider) ->
        $urlRouterProvider
            .when('/l', '/location')

        $stateProvider
            .state('location_lookup',
                url: '/location'
                views:
                    'content':
                        templateUrl: 'location.html'
                        controller: 'locationController'
                    'header':
                        template: 'Choose Your Location'
            )

# location lookup and state manager
class Location extends Controller
    constructor: ($scope, $state, geolocation, leafletData) ->
        $scope.searching = false
        $scope.error_message = ''
        # geo object
        $scope.location = false

        # leaflef base objects
        $scope.markers =
            user_marker:
                focus: true
                title: "Marker"
                draggable: false
                label:
                    message: "This is you!"
                    options:
                        noHide: true
        $scope.center =
            zoom: 13

        $scope.existing_locations = {
            # North Tulsa - N Hartford and E Virgin
            'North Tulsa': {lat: 36.184799, lng: -95.984105}
            # Midtown - 25th and Utica
            'Midtown Tulsa': {lat: 36.125700, lng: -95.967581}
            # South Tulsa - 85th and South Pittsburgh
            'South Tulsa': {lat: 36.039897, lng: -95.932032}
        }

        # get the user's current location
        $scope.get_location = ->
            return if $scope.searching is true
            $scope.searching = true
            # reset previously found location
            $scope.location = false
            $scope.location_promise = geolocation.getLocation()
            $scope.location_promise.then (geo) ->
                $scope.location = {lat: geo.coords.latitude, lng: geo.coords.longitude}
                angular.extend($scope.markers.user_marker, $scope.location)
                angular.extend($scope.center, $scope.location)
                $scope.searching = false
                $scope.error_message = ''
            , (error) ->
                $scope.error_message = error
                $scope.searching = false

        $scope.get_location()

        # accepts lat/lng obj
        $scope.retreive_location = (location) ->
            $state.go('score', location)

        leafletData.getMap('location-map').then (map) ->
            map.dragging.disable()
            map.touchZoom.disable()
            map.doubleClickZoom.disable()
            map.scrollWheelZoom.disable()
            map.boxZoom.disable()
            map.keyboard.disable()

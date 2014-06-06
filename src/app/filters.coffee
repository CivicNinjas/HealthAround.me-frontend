angular.module('ham').filter 'ucfirst', ->
    (string) ->
        # only work with da numbars
        return string if not angular.isString(string)
        return string.charAt(0).toUpperCase() + string.slice(1)


angular.module('ham').filter 'letter_score', ->
    (score) ->
        # only work with da numbars
        return score if not angular.isNumber(score)
        # take 0 - 1 and select a letter
        try
            ['F','F','D','D','C','C','B','B','A','A','A'][Math.floor(score * 10)]
        catch e
            return score

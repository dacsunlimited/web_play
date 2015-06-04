angular.module("app").directive "menuLink", ->
    scope:
        section: '='
    template: '''
        <md-button
            label="{{section.heading | translate}}"
            ng-class="{'active' : isSelected()}"
            ui-sref-active="active"
            ui-sref="{{section.route}}">
            <i class="fa {{section.icon}} fa-fw"></i>
          {{section.heading | translate}}
        </md-button>
    '''
    # link: ($scope, $element) ->
    #     controller = $scope.$parent
    #
    #     $scope.isSelected = ->
    #       return controller.isSelected($scope.section)
    #
    #     $scope.focusSection = ->
    #         # // set flag to be used later when
    #         # // $locationChangeSuccess calls openPage()
    #         controller.autoFocusContent = true

# angular.module("app.directives").directive "menuToggle", ->
#     scope:
#         section: '='
#     template: '''
#         <md-button class="md-button-toggle"
#           ng-click="toggle()"
#           aria-controls="docs-menu-{{section.name | nospace}}"
#           aria-expanded="{{isOpen()}}">
#           <div flex layout="row">
#             {{section.name}}
#             <span flex=""></span>
#             <span aria-hidden="true" class="md-toggle-icon"
#             ng-class="{'toggled' : isOpen()}">
#               <md-icon md-svg-src="md-toggle-arrow"></md-icon>
#             </span>
#           </div>
#           <span class="md-visually-hidden">
#             Toggle {{isOpen()? 'expanded' : 'collapsed'}}
#           </span>
#         </md-button>
#
#         <ul ng-show="isOpen()" id="docs-menu-{{section.name | nospace}}" class="menu-toggle-list">
#           <li ng-repeat="page in section.pages">
#             <menu-link section="page"></menu-link>
#           </li>
#         </ul>
#     '''
#     link: ($scope, $element) ->
#         controller = $element.parent().controller()
#
#         $scope.isOpen = ->
#             return controller.isOpen($scope.section)
#
#         $scope.toggle = ->
#             controller.toggleOpen($scope.section)
#
#         parentNode = $element[0].parentNode.parentNode.parentNode
#         if parentNode.classList.contains 'parent-list-item'
#             heading = parentNode.querySelector 'h2'
#             $element[0].firstChild.setAttribute 'aria-describedby', heading.id

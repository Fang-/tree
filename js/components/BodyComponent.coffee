clas    = require 'classnames'

load       = require './LoadComponent.coffee'
query      = require './Async.coffee'
reactify   = require './Reactify.coffee'

TreeActions = require '../actions/TreeActions.coffee'

Comments    = require './CommentsComponent.coffee'
Plan        = require './PlanComponent.coffee'

util        = require '../utils/util.coffee'

recl   = React.createClass
rele   = React.createElement
{div,p,img,a,input}  = React.DOM

# named = (x,f)->  f.displayName = x; f
  
extras =
  spam: recl
    displayName: "Spam"
    render: ->
      if document.location.hostname isnt 'urbit.org'
        return (div {})
      (div {className:'spam'},
        (a {href:"http://urbit.org#sign-up"}, "Sign up")
        " for our newsletter."
      )

  logo: recl 
    displayName: "Logo"
    render: ->
      {color} = @props
      if color is "white" or color is "black"  # else?
        src = "//storage.googleapis.com/urbit-extra/logo/logo-#{color}-100x100.png"
      (a {href:"http://urbit.org",style:{border:"none"}}, 
       (img {src,className:"logo first"})
      )

  plan: Plan


  next: query {
    path:'t'
    kids:
      name:'t'
      head:'r'
      meta:'j'
  }, recl
    displayName: "Next"
    render: ->
      curr = @props.kids[@props.curr]
      if curr?.meta?.next
        keys = util.getKeys @props.kids
        if keys.length > 1
          index = keys.indexOf(@props.curr)
          next = index+1
          if next is keys.length then next = 0
          next = keys[next]
          next = @props.kids[next]

          if next
            return (div {className:"link-next"},
              (a {href:"#{@props.path}/#{next.name}"}, "Next: #{next.meta.title}")
            )
      return (div {},"")

  comments: Comments

  footer: recl
    displayName: "Footer"
    render: ->
      (div {className:"footer"}, (p {}, "This page was served by Urbit."))  

module.exports = query {
  body:'r'
  name:'t'
  path:'t'
  meta:'j'
  sein:'t'
}, (recl
  displayName: "Body"
  render: ->
    extra = (name,props={})=> 
      if @props.meta[name]? then React.createElement extras[name], props
    
    containerClas = clas
      "col-md-10":true
      "col-md-offset-3":(@props.meta.anchor isnt 'none')
      body:true
    bodyClas = clas (@props.meta.layout?.split ',')    

    div {className:containerClas,'data-path':@props.path},[
      (div {
          key:"body"+@props.path
          bodyClas
          },
        extra 'spam'
        extra 'logo', color: @props.meta.logo
        extra 'plan'
        reactify @props.body
        extra 'next', {dataPath:@props.sein,curr:@props.name}
        extra 'comments'
        extra 'footer'
      )
    ]
), (recl
  render: -> (div {className:"col-md-offset-3 col-md-10"}, rele(load))
)

local class = require 'me.strangepan.libs.util.v1.class'
local builder = require 'me.strangepan.libs.util.v1.builder'
local Rx = require 'libs.rxlua.rx'
local assert_that = require 'me.strangepan.libs.truth.v1.assert_that'
local ternary = require 'me.strangepan.libs.util.v1.ternary'

local Scope = class.build()

function Scope.builder()
  if not Scope._builder then
    Scope._builder = builder.builder()
        :field {name = 'update', required = true}
        :field {name = 'draw', required = true}
        :builder_function(
            function(params)
              return Scope(params.update, params.draw)
            end)
        :build()
  end
  return Scope._builder
end

function Scope:_init(update, draw)
  local update_observable = assert_that(update):is_instance_of(Rx.Observable):and_return()
  local draw_observable = assert_that(draw):is_instance_of(Rx.Observable):and_return()

  self._is_running = Rx.BehaviorSubject.create(true)

  self._on_process_frame = Rx.Subject.create()
  self._on_commit_frame = Rx.Subject.create()
  self._on_prepare_frame = Rx.Subject.create()

  self._subscriptions = Rx.CompositeSubscription.create(
      self._is_running:map(function(r) ternary(r, update_observable, Rx.Observable.never()) end)
          :switch()
          :subscribe(
              function(dt)
                self._on_prepare_frame:onNext()
                self._on_process_frame:onNext(dt)
                self._on_commit_frame:onNext()
              end,
              function(error)
                self._on_prepare_frame:onError(error)
                self._on_process_frame:onError(error)
                self._on_commit_frame:onError(error)
              end,
              function()
                self._on_prepare_frame:onCompleted()
                self._on_process_frame:onCompleted()
                self._on_commit_frame:onCompleted()
              end)
  )

  self._on_draw = draw_observable:map()
end

function Scope:events()
  return {
    on_prepare_frame = self._on_prepare_frame,
    on_process_frame = self._on_process_frame,
    on_commit_frame = self.on_commit_frame,
    on_draw = self._on_draw,
  }
end

function Scope:pause()
  self._is_running(false)
end

function Scope:resume()
  self._is_running(true)
end

function Scope:destroy()
  self._subscriptions:unsubscribe()
end

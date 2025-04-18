# rubato

- [Background and explanation](#background)
- [How to actually use it](#usage)
- [But why though?](#why)
- [Arguments and Methods](#arguments-methods)
- [Custom Easing Functions](#easing)
- [Installation](#installation)
- [Why the name?](#name)
- [Todo](#todo)

Basically like [awestore](https://github.com/K4rakara/awestore) but not really.

Join the cool curve crew

<!-- look colleges might see this and think its distasteful so I'm commenting it out for the moment
<img src="https://cdn.discordapp.com/attachments/702548961780826212/879022533314216007/download.jpeg" height=160>-->

<h1 id="background">Background and Explanation</h1>

The general premise of this is that I don't understand how awestore works. That and I really wanted to be able to have an interpolator that didn't have a set time. That being said, I haven't made an interpolator that doesn't have a set time yet, so I just have this instead. It has a similar function to awestore but the method in which you actually go about doing the easing is very different.

When creating an animation, the goal is to make it as smooth as humanly possible, but I was finding that with conventional methods, should the animation be interrupted with another call for animation, it would look jerky and inconsistent. You can see this jerkiness everywhere in websites made by professionals and it makes me very sad. I didn’t want that for my desktop so I used a bit of a different method.

This jerkiness is typically caused by discontinuous velocity graphs. One moment it’s slowing down, and the next it’s way too fast. This is caused by just lazily starting the animation anew when already in the process of animating. This kind of velocity graph looks like this:

<img src="images/disconnected_graph.png" alt="Disconnected Velocity Graph" height=160/>

Whereas rubato takes into account this initial velocity and restarts animation taking it into account. In the case of one wanting to interpolate from one point to another and then back, it would look like this:

<img src="images/connected_graph.png" alt="Connected Velocity Graph" height=160/>

<sub><sup>okay maybe my graph consistancy is trash, what can I do...</sup></sub>

These are what they would look like with forwards-and-back animations. A forwards-than-forwards animation would look more like this, just for reference:

<img src="images/forwards_forwards_graph.png" alt="Forwards ForwardsGraph" height=160/>

To ask one of you to give these graphs as inputs, however, would be really dumb. So instead we define an intro function and its duration, which in the figure above is the `y=x` portion, an outro function and its duration, which is the `y=-x` portion, and the rest is filled with constant velocity. The area under the curve for this must be equal to the position for this to end up at the correct position (antiderivative of velocity is position). If we know the area under the curve for the intro and outro functions, the only component we need to ensure that the antiderivative is equal to the position would be the height of the graph. We find that with this formula:

$$m=\frac{d + ib(F_i(1)-1)}{i(F_i(1)-1) + o(F_o(1)-1) + t}$$

where `m` is the height of the plateau, `i` is intro duration, `F_i` is the antiderivative of the intro easing function, `o` is outro duration, `F_o` is the antiderivative of the outro easing function, `d` is the total distance needed to be traveled, `b` is the initial slope, and `t` is the total duration.

We then simulate the antiderivative by adding `v(t)` (or the y-value at time `t` on the slope graph) to the current position 30 times per second (by default, but I recommend 60). There is some inaccuracy since it’s not a perfect antiderivative and there’s some weirdness when going from positive slopes to negative slopes that I don’t know how to intelligently fix (I have to simulate the antiderivative beforehand and multiply everything by a coefficient to prevent weird errors), but overall it results in good looking interruptions and I get a dopamine hit whenever I see it in action.

There are a couple small issues that I can’t/don’t know how to fix mathematically:
- It’s not perfectly accurate (it is perfectly accurate as `dt` goes to zero) which I don’t think is possible to fix unless I stop simulating the antiderivative and actually calc out the function, which seems time inefficient
- When going from a positive m to a negative m, or in other words going backwards after going forwards in the animation, it will always undershoot by some value. I don’t know what that value is, I don’t know where it comes from, I don’t know how to fix it except for lots and lots of time-consuming testing, but it’s there. To compensate for this, whenever there’s a situation in which this will happen, I simulate the animation beforehand and multiply the entire animation by a corrective coefficient to make it do what I want
- Awesome is kinda slow at redrawing imaages, so 60 redraws per second is realistically probably not going to happen. If you were to, for example, set the redraws per second to 500 or some arbitrarily large value, if I did nothing to dt, it would take forever to complete an animaiton. So since I can't fix awesome, I just (by default but this is optional) limit the rate based on the time it takes for awesome to render the first frame of the animation (Thanks Kasper for pointing this out and showing me a solution).

So that’s how it works. I’d love any contributions anyone’s willing to give. I also have plans to create an interpolator without a set duration called `target` as opposed to `timed` when I have the time (or need it for my rice).

<h1 id="usage">How to actually use it</h1>

So to actually use it, just create the object, give it a couple parameters, give it some function to 
execute, and then run it by updating `target`! In practice it'd look like this:

```lua
timed = rubato.timed {
    duration = 1/2, --half a second
    intro = 1/6, --one third of duration
    override_dt = true, --better accuracy for testing
    subscribed = function(pos) print(pos) end
}

--you can also achieve the same effect as the `subscribed` parameter with this:
--timed:subscribe(function(pos) print(pos) end)

--target is initially 0 (unless you set pos otherwise)
timed.target = 1
-- Here it prints out this:
-- 0
-- 0
-- 0.02
-- 0.06
-- 0.12
-- 0.2
-- 0.3
-- 0.4
-- 0.5
-- 0.6
-- 0.7
-- 0.8
-- 0.88
-- 0.94
-- 0.98
-- 1
-- 1
-- First 0 is because when you initially subscribe a function
-- it calls that function at the current position, which is 0
-- Last zero is because it'll snap to the exact position in 
-- case of minor error which can come about from floating point
-- math or correcting for frameskips

--When called after it finishes printing, this would print out
--the same numbers but in reverse, sending it back from 1 to 0
timed.target = 0
```

If you're familiar with the awestore api and don't wanna use what I've got, you can use those methods 
instead if you set `awestore_compat = true`. It’s a drop-in replacement, so your old code should work perfectly with it. If it doesn’t, please make an issue and I’ll do my best to fix it. Please include the broken code so I can try it out myself.

So how do the animations actually look? Let’s check out what I (at one point) use(ed) for my workspaces:

```lua
timed = rubato.timed {
    intro = 0.1,
    duration = 0.3
}
```

![Normal Easing](./images/trapezoid_easing.gif)

The above is very subtly eased. A somewhat more pronounced easing would look more like this:

```lua
timed = rubato.timed {
    intro = 0.5,
    duration = 1,
    easing = rubato.quadratic --quadratic slope, not easing
}
```

![Quadratic Easing](./images/quadratic_easing.gif)

The first animation’s velocity graph looks like a trapezoid, while the second looks like the graph shown below. Note the lack of a plateau and longer duration which gives the more pronounced easing:

![More Quadratic Easing](./images/triangleish.png)

<h1 id="why">But why though?</h1>

Why go through all this hassle? Why not just use awestore? That's a good question and to be fair you can use whatever interpolator you so choose. That being said, rubato is solely focused on animation, has mathematically perfect interruptions and I’ve been told it also looks smoother.

Furthermore, if you use rubato, you get to brag about how annoying it was to set up a monstrous derivative just to write a custom easing function, like the one shown in [Custom Easing Function](#easing)'s example. That's a benefit, not a downside, I promise.

Also maybe hopefully the code should be almost digestible kinda maybe. I tried my best to comment and documentate, but I actually have no idea how to do lua docs or anything.

Also it has a cooler name

<h1 id="arguments-methods">Arguments and Methods</h1>

**For rubato.timed**:

Arguments (in the form of a table):
 - `duration`: the total duration of the animation
 - `rate`: the number of times per second the timer executes. Higher rates mean smoother animations and less error.
 - `prop_intro`: when `true`, `intro`, `outro` and `inter` represent proportional values; 0.5 would be half the duration. (def. `false`)
 - `pos`: the initial position of the animation (def. `0`)
 - `intro`: the duration of the intro
 - `outro`: the duration of the outro (def. same as `intro`\*)
 - inter: the duration of intermittent animations (def. same as `intro`\*)
 - `easing`: the easing table (def. `interpolate.linear`)
 - `easing_outro`: the outro easing table (def. as `easing`)
 - `easing_inter`: the "intermittent" easing table, which defines which easing to use in the case of animation interruptions (def. same as `easing`)
 - `subscribed`: a function to subscribe at initialization (def. `nil`)
 - `override_simulate`: when `true`, will simulate everything instead of just when `dx` and `b` have opposite signs at the cost of having to do a little more work (and making my hard work on finding the formula for `m` worthless :slightly_frowning_face:) (def. `false`)
 - `rapid_set`: 
 - `override_dt`: overrides the difference in time it takes to redraw the screen and just uses 1/rate no matter what. This results in slightly more accurate animations but they may take longer if awesome takes too long to redraw the screen. (def. `false`)
 - `clamp_position`: ensures the position does not exceed the target, essentially preventing overshooting (def. `false`)
 - `awestore_compat`: make api even *more* similar to awestore's (def. `false`)
 - `log`: it would print additional logs, but there aren't any logs to print right now so it kinda just sits there (def. `false`)
 - `debug`: basically just tags the timed instance. I use it in tandem with `manager.timed.override.forall`

All of these values (except awestore_compat and subscribed) are mutable and changing them will change how the animation looks. I do not suggest changing `pos`, however, unless you change the position of what's going to be animated in some other way

\*unless `outro + intro > 1`, it will instead go for the largest allowable outro time. Ex: duration = 1, intro = 0.6, then outro will default to 0.4.

Properties:
 - `target`: when set, sets the target and starts the animation, otherwise returns the target
 - `pause`: if true, the timer will have its animation suspedned until set to false again
 - `running`: immutable, returns true if an animation is in progress

Methods are as follows:
 - `timed:subscribe(func)`: subscribe a function to be ran every refresh of the animation
 - `timed:unsubscribe(func)`: unsubscribe a function
 - `timed:fire()`: run all subscribed functions at current position (you may provide it with arguments `pos`, `time` and `dx` manually if you wish, otherwise it'll use the values of the timed object) 
 - `timed:abort()`: stop the animation at the current position

Awestore compatibility functions (`awestore_compat` must be true):
 - `timed:set(target_new)`: sets the position the animation should go to, effectively the same as setting target
 - `timed:initial()`: returns the intiial position
 - `timed:last()`: returns the target position, effectively the same as `timed.target`

Awestore compatibility properties:
 - `timed.started`: subscribable table which is called when the animation starts or is interrupted
   + `timed.started:subscribe(func)`: subscribes a function
   + `timed.started:unsubscribe(func)`: unsubscribes a function
   + `timed.started:fire()`: runs all subscribed functions
 - `timed.ended`: subscribable table which is called when the animation ends
   + `timed.ended:subscribe(func)`: subscribes a function
   + `timed.ended:unsubscribe(func)`: unsubscribes a function
   + `timed.ended:fire()`: runs all subscribed functions

**builtin easing functions**
 - `easing.zero`: linear easing, zero slope
 - `easing.linear`: linear slope, quadratic easing
 - `easing.quadratic`: quadratic slope, cubic easing
 - `easing.bouncy`: the bouncy thing as shown in the example

**functions for setting default values**
 - (DEPRECIATED) `rubato.set_def_rate(rate)`: set default rate for all interpolators, takes an `int`. Please use instead `manager.timed.default.rate = rate`
 - (DEPRECIATED) `rubato.set_override_dt(value))`: set default for override_dt for all interpolators, takes a `bool`. Please use instead `manager.timed.default.override_dt = value`

 **For rubato.manager**

 - `manager.timed.default`: a table containing properties of timed objects as keys and their default values as values. Updating values in this table changes those defaults. Ex: `manager.timed.default.rate = 60` sets default rate to 60 fps
 - `manager.timed.override`: a table with accessors which set properties of all tables. Updating values in this table changes the properties of all tables. Ex: `manager.timed.override.is_instant = true` makes all animations instantaneous globally
 - `manager.timed.override.clear()`: resets all timeds to their initial values
 - `manager.timed.override.forall(func)`: run some function for all timed objects. Parameter to function is a single timed object. Ex: `manager.timed.override.forall(function(timed) print(timed) end)` prints all timeds

<h1 id="easing">Custom Easing Functions</h1>

To make a custom easing function, it's pretty easy. You just need a table with two values:

 - `easing`, which is the function of the slope curve you want. So if you want quadratic easing
   you'd take the derivative, which would result in linear easing. **Important:** `f(0)=0` and
   `f(1)=1` must be true for it to look nice.
 - `F`, which is basically just the value of the antiderivative of the easing function at `x=1`.
   This is the antiderivative of the scaled function such that ``(0,0) ⋃ (1,1) ∈ f``.

In practice, creating your own easing would look like this:

1. Go to [easings.net](https://easings.net)

For the sake of this tutorial, we'll do both an easy easing and a complex one. The easy easing will
be the beautifully simple and quite frankly obvious quadratic. The much worse easing will be "ease
in elastic."

2. Find the necessary information

For quadratic we already know the function: `y=x^2`. I don't even need to use latex it's that easy.

For ease in elastic, we use the function given [here](https://easings.net/#easeInElastic): 

$$f(x)=-2^{10x - 10}\times \sin\left(-\frac{43}{6} \pi + \frac{20}{3} \pi x\right)$$

3. Take the derivative 

Quadratic: `y=2x`, easy as that.

**Important:** Look. Computers aren't the greatest at indefinite mathematics. As such, it's
possible that, like myself, you will have a hard time getting the correct derivative if it's as
complicated as these here. Don't be discouraged, however! Sagemath (making sure not to factor
anything) could correctly do out this math, even if I had a bit of a scare realizing that when I
was factoring it I was just being saved by `override_simulate` being accidentally set to true.

Anyways, use sagemath and jupyter notebook. I don't know if all sagemaths come with it
preinstalled, but nix makes it so easy that all I have to do is `sage -n jupyter` and it'll open it
right up. `%display latex` in jupiter makes it look pretty, whereas `%display ascii_art` will make
it look *presentable* in tui sagemath.

The derivative (via sagemath) is as follows:  

$$f^\prime (x)=-\frac{20}{3} \pi 2^{10 x - 10} \cos\left(-\frac{43}{6} \pi + \frac{20}{3} \pi x\right) - 10 \cdot 2^{10 x - 10} \log\left(2\right) \sin\left(-\frac{43}{6} \pi + \frac{20}{3} \pi x\right)$$

4. Ensure that `(0,0) ∈ f'`

Quadratic: `2*0 = 0` so we're good

Ease in elastic not so much, however:

$$f^\prime (0)=\frac{5}{1536} \sqrt{3} \pi - \frac{5}{1024} \log\left(2\right)$$

We'll subtract this value from `f(x)` so that our new `f(x)`, let's say `f_2(x)` is such that `(0,0) ∈ f_2`

5. Ensure that `(1,1) ∈ f_2`

Quadratic:  This means we have to do a wee bit of work: `f(1)=2`, so to counteract this,
we'll create a new (and final) function that we can call `f_e` (easing function) by dividing `f(x)`
by `f(1)` (scaling it down).

```
f(1)=2
f(x)/f(1) = 2x / 2 = x,
f_e(x)=x
```

Easy as that!

Or so you thought. Now let's check the same for ease in elastic:

$$f_2(1)=-\frac{5}{1536} \sqrt{3} \pi + \frac{10245}{1024} \log\left(2\right)$$

Hence the need for sagemath. Once we divide the two we get our final easing function, this:

$$f_e(x)=\frac{4096 \pi 2^{10 x - 10} \cos\left(-\frac{43}{6} \pi + \frac{20}{3} \pi x\right) + 6144 \cdot 2^{10 x - 10} \log\left(2\right) \sin\left(-\frac{43}{6} \pi + \frac{20}{3} \pi x\right) + 2 \sqrt{3} \pi - 3 \log\left(2\right)}{2 \sqrt{3} \pi - 6147 \log\left(2\right)}$$

What on god's green earth is that. Well whatever, at least it works.

6. Finally, we get the definite integral from 0 to 1 of our `f(x)`

For `f(x)=x` we can do that in our heads, it's just `1/2`.

Ease in elastic is a bit trickier to do in your head. You can do this with sagemath and eventually get this:

$$\frac{20 \sqrt{3} \pi - 30 \log\left(2\right) - 6147}{10 {\left(2 \sqrt{3} \pi - 6147 \log\left(2\right)\right)}}$$

So this all looked pretty daunting probably, and to be honest it took me hours of either not using
sage (I tried with wolfram alpha for a good hour) or using sage incorrectly (it took three months
to realize that this entire section of the readme was wrong and that using `factor` made it
incorrect), but now that I have this easy little code snippet you can use for sage it shouldn't be
as much of a hastle for you.

```python
from sage.symbolic.integration.integral import definite_integral
function('f')
f(x)='''your function goes here'''
f(x)=derivative(f(x), x)
f(x)=f(x)-f(0)
f(x)=f(x)/f(1)
print(f(x)) # easing
print(definite_integral(f(x), x, 0, 1)) # F
```

So the thing with using `factor` is that, while on some weird other version of sage I was geting a
bunch of 0.49999s which wouldn't round to .5, the result was straight up wrong. So I advise against
it, and if you can't do the derivative then sucks to suck I guess (just lmk in an issue or
something and I'll try my very best).

7. Now we just have to translate this into an actual lua table. 

Quadratic, as usual, is easy.
```lua
local quadratic = {
	F = 1/2 -- F(1) = 1/2
	easing = function(t) return t end -- f(x) = x, I just use t for "time"
}
```

Ease in elastic, as usual, is not. At one point I had the willpower to try and optimize operations,
but I really don't want to simplify those equations and I can't trust `factor`, so for now it stays
as is. If it irks you, make a pull request and save us both.

```lua
local bouncy = {
	F = (20*math.sqrt(3)*math.pi-30*math.log(2)-6147) /
		(10*(2*math.sqrt(3)*math.pi-6147*math.log(2))),
	easing = function(t) return
(4096*math.pi*math.pow(2, 10*t-10)*math.cos(20/3*math.pi*t-43/6*math.pi)
+6144*math.pow(2, 10*t-10)*math.log(2)*math.sin(20/3*math.pi*t-43/6*math.pi)
+2*math.sqrt(3)*math.pi-3*math.log(2)) /
(2*math.pi*math.sqrt(3)-6147*math.log(2))
	end
}

-- how it would actually look in a timed object
timed = rubato.timed {
    intro = 0, --we'll use this as an outro, since it's weird as an intro
    outro = 0.7,
    duration = 1,
    easing = bouncy
}
```

We did it! Now to check whether or not it actually works

![Beautiful](./images/beautiful.gif)

While you can't see its full glory in 25 fps gif form, it really is pretty cool.  Furthermore, if it
works with *that* function, it'll probably work with anything. As long as you have the correct
antiderivative and it's properly scaled, you can probably use any (real, differentiable) function
under the sun.

Note that if it's not properly scaled, this can be worked around (if you're lazy and don't care
about a bit of a performance decrease). You can set `override_simulaton` to true. However, it is
possible that it will not perform exactly as you expected if you do this so do your best to just
find the derivative and antiderivative of the derivative.

<h1 id="install">Installation</h1>

So actually telling people how to install this is important, isn't it

It supports luarocks, so that'll cut it if you want a really really easy install, but it'll install
it in some faraway lua bin where you'll probably leave it forever if you either stop using rubato or
stop using awesome. However, it's certainly the easiest way to go about it. I personally don't like
doing this much because it adds it globally and I'm only gonna be using this with awesome, but it's
a really easy install.

```
luarocks install rubato
```

Otherwise, somewhere in your awesome directory, (I use `~/.config/awesome/lib`) you can run this
command: 

```
git clone https://github.com/andOrlando/rubato.git
```

Then, whenever you actually want to use rubato, do this at the start of the lua file: `local rubato
= require "lib.rubato"`

<h1 id="name">Why the name?</h1>

Because I play piano so this kinda links up with other stuff I do, and rubato really well fits the
project. In music, it means "push and pull of tempo" basically, which really is what easing is all
about in the first place. Plus, it'll be the first of my projects without garbage names
("minesweperSweeper," "Latin Learning").

<h1 id="todo">Todo</h1>

 - [ ] add `target` function, which rather than a set time has a set distance.
 - [x] improve intro and outro arguments (asserts, default values, proportional intros/outros)
 - [x] get a better name... (I have a cool name now!)
 - [x] make readme cooler
 - [x] have better documentation and add to luarocks
 - [x] remove gears dependency 
 - [ ] only apply corrective coefficient to plateau
 - [x] Do `prop_intro` more intelligently so it doesn't have to do so many comparisons (done maybe kinda?)
 - [x] Make things like `abort` more useful
 - [x] Merge that pr by @Kasper so instant works
 - [x] Add a manager (this proceeds the above todo thing)
 - [ ] Make forall more useable and add tags and stuff
 - [ ] Fix that bug where you could set stuff manually (this might already be fixed I just haven't tested it)
 - [ ] Make is_instant even faster by just short circuiting `set`

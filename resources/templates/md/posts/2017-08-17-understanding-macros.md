{:title "Macros"
 :layout :post
 :author "AJ Taylor"
 :tags  ["Clojure" "Macros"]}



### Macros With Clojure

One of the benefits of Clojure is that it's a dialect of lisp and homoiconic. There are already many [great blog posts](https://spin.atomicobject.com/2013/07/23/homoiconicity-clojure-macros/) on homoiconicity so I won't go into it much. The main idea though is that when clojure is parsed, it already looks like an AST due to the fact that the code itself is a data structure. This helps mitigate some of the complexity that is introduced when implementing meta-programming.

One of my favorite examples of the power of macros in Clojure is in the book [Clojure Programming](http://shop.oreilly.com/product/0636920013754.do). They give the example of the Java for loop that was enhanced.

```
for (int i = 0; i < collection.size(); i++) {
    SomeType var = (SomeType)collection.get(i);
    ...
}

//enhanced and more conise version
for (SomeType var : collection) {
    ...
}
```

"Adding enhanced for to Java requires a change at the compiler level, and the average user does not have the knowledge or ability to make that change. So what did Java developers do for those first eight years without this helpful language feature? They lived without it.

In contrast, any Clojure programmer, in matter of minutes and in a few lines of unprivileged Clojure code, can write a macro to add an imperative looping construct to Clojure that is similar to Java 5’s enhanced for"

```clojure
(defmacro foreach [[sym coll] & body]
  `(loop [coll# ~coll]
     (when-let [[~sym & xs#] (seq coll#)]
       ~@body
       (recur xs#))))
;= #'user/foreach
(foreach [x [1 2 3]]
  (println x))
; 1
; 2
; 3
```

### Why Macros?

* Macros allow the compiler to be extended by user code.

* Macros allow you to derive functionality from primitive functions and special forms.

* Macros can allow code to be more declaritive than imperitive.

* If you want to make your code more concise and clear as to what your intent is.

* If you want to add new control flow structures to your language as a library.

* If you want to abstract away code from the caller and make your code's purpose more obvious.

* In some cases the only way of getting rid duplicate code is to create a macro.

* Specifically in Clojurescript when you want to leverage the JVM at compiletime before runtime happens on the Javascript VM.

* When you want to speed things up and implement computational work at compile time.

### Building Blocks of Macros

Below are the basic building blocks required when building macros:

* Quote: '

```clojure
'(+ 1 2 3)
=> (+ 1 2 3)
```

* Unquote: ~ (Usually used within a syntax-quote)

```
(let [x 2]
    `(1 ~x 3))
=> (1 2 3)
```

* Syntax Quote: ` (Looks very similar to a quote but it's not!)

```
(let [x 2]
    `(1 x 3))
=> (1 user/x 3)
```

* Unquote Splice: ~@

```
`(1 2 ~(list 3 4))   =>  (1 2 (3 4))
`(1 2 ~@(list 3 4))  =>  (1 2 3 4)
```
* Auto Gensym #

```clojure
(defmacro m [] `(let [x# 1] x#))

(macroexpand '(m))
=> (let* [x__10466__auto__ 1] x__10466__auto__)
```

You'll notice I used macroexpand, this is a handy tool in the repl that allows you to see your code in between what is read and what is evaluated. (also known as macro expansion time)

### Limitations of Macros

Macros can't be passed as a higher order functions. For example, you wouldn't be able to map a collection over a macro. What is valid with a basic function is clojure isn't aloud with a macro. This is because macros don't always? evaluate their arguments before the actual macro, whereas a function would.

```clojure
(defn add-2 [x] (+ x 2))
=> #'user/add-2
(map add-2 (range 3))
=> (2 3 4)

;;Not aloud with macros
(defmacro add-2 [x] `(+ ~x 2))
=> #'user/add-2
(map add-2 (range 3))
=> CompilerException java.lang.RuntimeException: Can't take value of a macro: #'user/add-2
```
In some cases you are able to wrap an anonymous function around your macro as a work around, but as your macros get more complex it is more likely to not work.

```clojure
(map #(add-2 %) (range 3))
=> (2 3 4)
```

### Tips when creating macros

The main rule of macros is to never write a macro when a function will do. What I've read is that a clojure project should have no more than 5 macros. There are many opinions on this however and depending on the use case it can make sense to increase that limit. Paul Graham mentioned that his code base at ViaWeb consisted of about [25% macros](http://www.paulgraham.com/avg.html). Steve Yegge has also criticized the Clojure community for being [too prescriptive with coding styles](https://groups.google.com/d/msg/seajure/GLqhj_2915A/f-JpotiBTfAJ). For me personally I'd still try to remain within that limit to reduce complexity. If possible, break apart your macros so that within the macros you are calling helper functions instead of having it be apart of your macro.

Think in terms of data instead of code. In Colin Jones [book](https://pragprog.com/book/cjclojure/mastering-clojure-macros), he talks about an interesting method when thinking about macros and compares it to stepping on a ladder. When you expand a macro during the macro expansion process, you take a step up the ladder and shift from thinking in code to thinking in data. When you evaluate the macro you take a step down and think in terms of code. Depending on the amount of expansions per macro, you can be stepping up and down several steps.

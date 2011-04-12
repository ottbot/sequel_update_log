sequel-update-log
=================

This plugin will create a table to log the value of changed_columns when a value for :updated_by passed in the hash for @model.update

You can optionally provide a symbol with the name of a model to associate the log with.

Example:
--------
    class Foo < Sequel::Model
      plugin :update-log, :owner => :User
    end

    @f = Foo.first
    @f.update({:bar => "new value", :updated_by => @current_user})

--------
In this case, the table foo_log will be created, along with a FooLog model. 

This model has a many_to_one association with Foo, and Foo has one_to_many :logs, :class => :FooLog

Since we passed the :owner => :User option, the FooLog model will have a many_to_one :user association created.

You can set the value of :updated_by to a string in any case, to not associate the update with the owner model.

Instance of a log has the methods 'by' for the string value sent with :updated_by, or 'owner' for the associated model if provided..

Not sending a value of :updated_by to update will cause the record to be updated normally.

Documentation, tests, and improvements welcome!


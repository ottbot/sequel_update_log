module Sequel
  module Plugins

    module UpdateLog
      def self.configure(model, opts = {})
        model.log_table = opts[:table] || :"#{model.table_name}_log"
        model.name_key = opts[:name_key] || :updated_by
        model.log_owner_class = opts[:owner] ? Object.const_get(opts[:owner]) : nil
        model.date_proc = opts[:date_proc] || Proc.new { Time.now }
        model.key_for_log = opts[:key] || :"#{model.to_s.downcase}_id"

        model.create_log_model

        model.db.create_table? model.log_table do
          primary_key :id
          Integer model.key_for_log
          String :fields
          Integer :owner_id
          String :owner_plain
          DateTime :at
        end
      end
      
      module ClassMethods
        attr_accessor :log_table, :name_key, :date_proc, :key_for_log, :log_model, :log_owner_class
  
        def inherited(subclass)
          super
          subclass.log_table = log_table
          subclass.name_key = name_key
          subclass.date_proc = date_proc
          subclass.key_for_log = key_for_log
        end

        def create_log_model
          self.log_model = Object::const_set("#{model.to_s}Log".intern, Class::new(Sequel::Model(log_table)))
          
          one_to_many :log, :class => :"#{log_model}", :key => key_for_log
          if log_owner_class
            log_model.associate(:many_to_one, :owner, :class => :"#{log_owner_class}")
          end

        end
      end
  
      module InstanceMethods
        def update(hash)
          if by = hash.delete(model.name_key)
            set(hash)
            if modified?
              cols = changed_columns.join(', ')
              save_changes
              l = case by
                  when model.log_owner_class
                    {:owner_id => by.pk}
                  when String
                    {:owner_plain => by}
                  else
                    #TODO raise error here?
                    {:owner_plain => by.to_s}
              end
              
              add_log(l.merge(:fields => cols, :at => model.date_proc.call)) 
              self
            else
              nil
            end
          else
            # no one to attribute update so, so just update as normal
            update_restricted(hash, nil, nil)
          end
        end

        
      end
    end
  end
end


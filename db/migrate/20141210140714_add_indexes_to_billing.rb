class AddIndexesToBilling < ActiveRecord::Migration
  def change
    add_index(:billing_external_gateway_states, :external_gateway_id, name: 'external_gateway_states')
    add_index(:billing_external_gateway_states, :sync_id,             name:  'external_gateway_syncs')
    add_index(:billing_image_states,            :image_id,            name:            'image_states')
    add_index(:billing_image_states,            :sync_id,             name:             'image_syncs')
    add_index(:billing_instances,               :flavor_id,           name:        'instance_flavors')
    add_index(:billing_instance_states,         :instance_id,         name:         'instance_states')
    add_index(:billing_instance_states,         :sync_id,             name:          'instance_syncs')
    add_index(:billing_ip_states,               :ip_id,               name:               'ip_states')
    add_index(:billing_ip_states,               :sync_id,             name:                'ip_syncs')
    add_index(:billing_volume_states,           :volume_id,           name:           'volume_states')
    add_index(:billing_volume_states,           :sync_id,             name:            'volume_syncs')
  end
end

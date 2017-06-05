module Billing
  module LoadBalancers

    def self.sync!(from, to, sync)
      Rails.cache.delete("active_load_balancers")
      Project.with_deleted.each do |project|
        next unless project.uuid
        Billing.fetch_samples(project.uuid, "network.services.lb.pool.create", from, to).each do |lb_id, samples|
          create_new_lb(project.uuid, lb_id, samples, sync)
        end
      end
    end

    def self.usage(project_id, from, to)
      lbs = Billing::LoadBalancer.where(project_id: project_id)
      lbs.reject(&:terminated_at).each do |lb|
        unless active_load_balancers.include?(lb.lb_id)
          lb.update_columns terminated_at: Time.now
        end
      end
      lbs = lbs.select do |lb|
        (!lb.terminated_at && (lb.started_at < to)) || (lb.terminated_at && (lb.terminated_at < to && lb.terminated_at > from) && (lb.started_at < to && lb.started_at > from))
      end
      lbs.collect do |lb|
        start  = [lb.started_at, from].max
        finish = lb.terminated_at ? [lb.terminated_at, to].min : to
        hours = ((finish - start) / (60 ** 2)).ceil
        {
          lb_id: lb.lb_id,
          name:  lb.name,
          started_at: lb.started_at,
          terminated_at: lb.terminated_at,
          hours: hours,
          cost:  (hours * RateCard.lb_pool).nearest_penny
        }
      end
    end

    def self.active_load_balancers
      if Rails.env.staging?
        return ["03145f59-f8be-4459-808d-108d463f6911", "09314048-5bc4-4dff-9ec0-448cfdc7de9e", "0976e919-5305-4f0b-b924-97176a1abbcb", "0a628525-3708-4ffb-ac87-60c0ef4d66f5", "105558dd-fd87-4461-9f56-66acab5f46b4", "11cfbb6d-7d65-4057-a17f-873a3b545fb3", "142fc0fb-c53b-4c80-8716-194f585efd7d", "150aa6ad-b30a-407c-b63c-ff3bdb6ea2da", "1771736e-d37f-4d25-9820-8c976c549165", "1a9f30c3-38ea-4e2d-b894-de5b1aee65fd", "1deb891b-d417-46f0-88d6-e981cb9b4833", "2554fa79-47d6-474e-9e68-b789f3dba96e", "27cdfb38-0cc8-4726-9e30-90a08f42e6dd", "2a52f5eb-f22b-4418-9fc0-50a0e38acdbd", "2c9d70ac-0b55-4ef4-b1df-102114ae1a48", "2d73e606-fde6-4de2-9591-af40b04b58a9", "2e3be25b-bd68-44c7-8fc9-0e3ad4f0e94a", "2fcd8460-3691-4a99-a01f-0859ec36e816", "31fbfaec-19d5-4d05-a9fe-95b3b7cbb932", "33cc5b6c-562b-4819-a3ed-246031e84f4b", "381ecfeb-a03b-410a-ad4d-af547f9a7f9e", "39f88dd0-74be-472a-b896-6e8fa5465b1b", "3cbf0548-df73-409b-8663-731fbd2b543f", "4599f238-6965-4b16-8136-265698168550", "48262fd8-32df-4da5-8ff6-d170f9015cee", "4a891799-0b38-4362-99b3-4785b3a1cc24", "519c5a77-6272-495d-a9de-5f11ace9a295", "530f2b56-42f5-4d59-adc3-83db50224859", "53f7eb92-9f20-4923-8324-63bc49b10db1", "54171aba-dece-47f4-988c-b9cfd1612092", "5acf3445-b487-44df-8b78-164f5bbba111", "5b72ac87-f7b3-4b90-88ce-79585918324f", "5f61132b-9df9-40a8-97de-3941c36836f1", "65ebeff7-af7e-4381-bebf-a2d8a822abe2", "67d1a4eb-0ed2-4423-a945-2f56423b27ae", "6b41b909-84e3-49c4-bdfc-29c5961181b2", "6f61e0a6-ac76-48da-8306-e176ff3c1784", "74398f7f-4c39-45f0-a375-3683747fcf9c", "77d6e050-f297-433e-9e49-3109ad03b317", "7b30f20f-fc74-4b68-8c97-d552415bbee1", "7b952a1a-2aa0-45be-9d69-f4b7197f898d", "831915a3-335d-473b-8d39-ddf055f88df5", "836db625-83eb-45ec-915c-13131e5598af", "8388edc3-9af3-4497-b81b-2c352e0e7a32", "83adf57e-8414-4c35-8fc7-3476ccf875ee", "86721c0b-9f32-4b89-a51e-5ea5b31424a0", "8c61cbac-d4cc-4b66-9b96-f9e0e0af4285", "8d467dee-3cd0-4429-999b-a41ddf1e7ae8", "900e788a-b1f0-4102-8e6a-709831c25351", "95b85352-5a64-4381-a07b-634348e0d40a", "963dc2c9-daf1-4f63-ae2a-71e0742cace1", "96b15553-cae0-42c9-a054-9ef8f41e91a2", "9a40fce2-4af1-4220-aeb1-df852daff1e7", "9c31a9f6-3416-449b-be2e-adaba0dc805e", "9e0d18d7-edc5-492d-adbe-e2ada8815c7f", "a30c7f66-bc77-4691-af9d-671f6f3492e9", "a7c2e116-7e69-4da2-b38b-fc4bdbf26749", "aaace9c0-78eb-410f-8922-07df4d60657b", "aac66d25-3426-4196-890b-5eb981901ee6", "ad58339b-50b7-4c79-beac-6dfbfadd3f48", "ae2ce6bd-cbdc-4321-b3a6-ff7e2b6df925", "b16cc697-0787-4fab-baac-c4ef50c86c22", "b5c150a7-005f-465c-b61e-886d58945a9e", "b743d397-e7bb-4fb5-938a-00a1a19f4045", "bce6ef6e-5b68-4376-a2a1-9aef3ec0f7c9", "bdc356d9-85ab-49ec-83d0-973c51fbb1ff", "c1f342d9-77cc-4ab3-8f4f-71c2af4fec46", "c6b05181-ebc3-4ea5-8c93-fbe6452dd134", "c6da4990-962f-49e7-aeb8-00385d9aa397", "c6f5687f-bc50-4aa6-a515-48a24c614260", "c76d24d9-6140-4627-a7ce-a5b1c9413908", "caff4176-c105-4899-b381-7c63888e616e", "cf7c0366-81c3-40c2-8988-66990ae99c0e", "cf7f8d8e-b763-49c2-8412-038439241a08", "d0ea8d1f-08e5-4582-aa25-79b5e9ad1450", "d3f89538-3447-4964-ac1c-0e2fe8651767", "d41415e9-0872-4633-91ca-9e24727d6fe5", "dbaa62cb-acb0-4ee6-aa01-6f2f769cf66d", "dbe2f1e0-ef5b-4e58-8769-f41c1baa2706", "e571912c-46b0-45e8-926b-15f6b76dbd43", "e638eab4-b8f3-48c6-88cf-ca698e71243c", "e86a3a38-04e2-4367-ada9-f98e11c4ca81", "e937d12f-2289-44f4-b1b6-b2a95e16e57b", "f4b18985-8dbd-4c3a-87f0-3cd92b878f32", "f5a59ffb-32c8-4ac9-b3e3-b7d2e94fbac3", "fadfba59-20c8-4a0f-a0d6-c29420b04292", "fb32d3cf-ea60-4f19-90cd-524daa767e39", "fdaba00e-371e-4ed9-a949-24c16162372e"]
      end
      Rails.cache.fetch("active_load_balancers", expires: 10.minutes) do
        OpenStackConnection.network.list_lb_pools.body['pools'].map{|lb| lb['id']}
      end
    end

    def self.create_new_lb(project_id, lb_id, samples, sync)
      first_sample = samples[0]
      LoadBalancer.create lb_id: lb_id, project_id: project_id,
                          started_at: first_sample['recorded_at'],
                          name: first_sample['resource_metadata']['name'],
                          sync_id: sync.id,
                          user_id: first_sample['user_id']
    end

  end
end

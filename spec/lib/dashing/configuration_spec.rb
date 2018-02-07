RSpec.describe Dashing::Configuration do

  let(:instance) { Dashing::Configuration.new }

  it { expect(instance.engine_path).to            eq('/dashing') }
  # it { expect(instance.scheduler).to              be_a(::Rufus::Scheduler.new) }
  it { expect(instance.redis).to                  be_a(::ConnectionPool) }
  it { instance.redis.with { |r| expect(r).to     be_a(::Redis) } }

  # Redis
  it { expect(instance.redis_host).to             eq('127.0.0.1') }
  it { expect(instance.redis_port).to             eq('6379') }
  it { expect(instance.redis_password).to         be_nil }
  it { expect(instance.redis_timeout).to          eq(3) }
  it { expect(instance.redis_namespace).to        eq('dashing_events') }
  it "can gracefully shutdown redis" do
    config = Dashing::Configuration.new
    config.redis
    expect(config.instance_variable_get(:@redis)).not_to be_nil
    config.shutdown_redis
    expect(config.instance_variable_get(:@redis)).to be_nil
  end

  # Authorization
  it { expect(instance.auth_token).to             be_nil }
  it { expect(instance.devise_allowed_models).to  be_empty }

  # Jobs
  it { expect(instance.jobs_path.to_s).to    include('app/jobs') }

  # Dashboards
  it { expect(instance.default_dashboard).to      be_nil }
  it { expect(instance.dashboards_views_path.to_s).to include('app/views/dashing/dashboards') }
  it { expect(instance.dashboard_layout_path).to  eq('dashing/dashboard') }

  # Widgets
  it { expect(instance.widgets_views_path.to_s).to include('app/views/dashing/widgets') }
  it { expect(instance.widgets_js_path.to_s).to    include('app/assets/javascripts/dashing') }
  it { expect(instance.widgets_css_path.to_s).to   include('app/assets/stylesheets/dashing') }

end

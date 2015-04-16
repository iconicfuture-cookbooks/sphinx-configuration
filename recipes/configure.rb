#
# Cookbook Name:: sphinx-configuration
# Recipe:: configure
#
# Copyright 2015, Iconicfuture GmbH <thomas.liebscher@iconicfuture.com>
#
# This receipe configures the sphinx indexes

# template "#{node['sphinx']['install_path']}/sphinx.conf" do
#   source "sphinx.conf.erb"
#   owner node[:sphinx][:user]
#   group node[:sphinx][:group]
#   mode '0644'
#   variables :install_path => node['sphinx']['install_path']
# end

# build sphinx.conf from single sources

unless node['sphinx'].nil?
  unless node['sphinx']['sources'].nil?

    sources = ""
    indexes = ""

    node['sphinx']['sources'].each do |name, path|
        fileContent = IO.read(path)

        source = "source src_#{name}: src_base \n{\n#{fileContent}\n}\n"
        sources = sources << source

        index = <<DOC
index #{name} : base
{
    source = src_#{name}
    path   = #{node['sphinx']['install_path']}/#{name}
}\n
DOC
        indexes = indexes << index
    end

    template "#{node['sphinx']['install_path']}/sphinx.conf" do
      source "sphinx.conf.erb"
      owner node[:sphinx][:user]
      group node[:sphinx][:group]
      mode '0644'
      variables ({
        :install_path => node['sphinx']['install_path'],
        :sources      => sources,
        :indexes      => indexes
      })
    end

    # make final sphinx.conf available in repository
    bash "Copy sphinx.conf to right service repo" do
      code <<-EOH
        cp "#{node['sphinx']['install_path']}/sphinx.conf" "#{node['services']['right-service']['nginx']['root']}/sphinx"
        pwd >> /home/vagrant/tmp.txt
      EOH
    end

    template "#{node['sphinx']['install_path']}/wordforms.txt" do
      source "wordforms.txt.erb"
      owner node[:sphinx][:user]
      group node[:sphinx][:group]
      mode '0644'
      variables :install_path => node['sphinx']['install_path']
    end

    template "#{node['sphinx']['install_path']}/stopwords.txt" do
      source "stopwords.txt.erb"
      owner node[:sphinx][:user]
      group node[:sphinx][:group]
      mode '0644'
      variables :install_path => node['sphinx']['install_path'],
      :partials => { "#{node['services']['right-service']['nginx']['root']}/sql/src_rightsholder.conf.part.erb" => "rightsholder"}
    end

    execute "sphinx - rebuild index" do
        command "indexer --rotate --all"
        ignore_failure true
        user "root"
    end

  end
end
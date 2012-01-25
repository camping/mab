# -*- encoding: utf-8 -*-
require File.dirname(__FILE__) + '/lib/mab/version'
require 'date'

Gem::Specification.new do |s|
  s.name          = 'mab'
  s.version       = Mab::VERSION
  s.date          = Date.today.to_s

  s.authors       = ['Magnus Holm']
  s.email         = ['judofyr@gmail.com']
  s.summary       = 'Markup as Ruby'

  s.require_paths = %w(lib)
  s.files         = Dir["**/*"]

  s.add_development_dependency('rake')
  s.add_development_dependency('minitest')
end


require "set"

module Geminabox
  module GemListMerge
    def self.merge(local_gem_list, remote_gem_list, strategy:)
      strategy_for(strategy).merge(local_gem_list, remote_gem_list)
    end

    def self.strategy_for(strategy)
      case strategy
      when :local_gems_take_precedence_over_remote_gems
        LocalGemsTakePrecedenceOverRemoteGems
      when :combine_local_and_remote_gem_versions
        CombineLocalAndRemoteGemVersions
      else
        raise ArgumentError, "Merge strategy must be :local_gems_take_precedence_over_remote_gems (default) or :merge_local_and_remote_gem_versions"
      end
    end

    module LocalGemsTakePrecedenceOverRemoteGems
      def self.merge(local_gem_list, remote_gem_list)
        names = Set.new(local_gem_list.map { |gem| gem[:name] })
        local_gem_list + remote_gem_list.reject { |gem| names.include? gem[:name] }
      end
    end

    module CombineLocalAndRemoteGemVersions
      IGNORE_DEPENDENCIES = 0..-2

      def self.merge(local_gem_list, remote_gem_list)
        merged = local_gem_list + remote_gem_list
        merged.uniq! {|val| val.values[IGNORE_DEPENDENCIES] }
        merged.sort_by! {|x| x.values[IGNORE_DEPENDENCIES] }
        merged
      end
    end
  end
end

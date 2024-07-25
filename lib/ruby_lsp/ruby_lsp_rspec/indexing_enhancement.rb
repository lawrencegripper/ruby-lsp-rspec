# typed: strict
# frozen_string_literal: true

module RubyLsp
  module RSpec
    class IndexingEnhancement
      extend T::Sig
      include RubyIndexer::Enhancement

      sig do
        override.params(
          index: RubyIndexer::Index,
          owner: T.nilable(RubyIndexer::Entry::Namespace),
          node: Prism::CallNode,
          file_path: String,
        ).void
      end
      def on_call_node(index, owner, node, file_path)
        return if node.receiver

        name = node.name

        case name
        when :let
          arguments = node.arguments
          return unless arguments

          return if arguments.arguments.count != 1

          method_name_node = T.must(arguments.arguments.first)

          method_name = case method_name_node
          when Prism::StringNode
            method_name_node.slice
          when Prism::SymbolNode
            method_name_node.unescaped
          end

          return unless method_name

          index.add(RubyIndexer::Entry::Method.new(
            method_name,
            file_path,
            method_name_node.location,
            method_name_node.location,
            [],
            [RubyIndexer::Entry::Signature.new([])],
            RubyIndexer::Entry::Visibility::PUBLIC,
            owner,
          ))
        end
      end
    end
  end
end

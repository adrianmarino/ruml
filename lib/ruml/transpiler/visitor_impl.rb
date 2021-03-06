import 'RumlBaseVisitor'
import 'RumlLexer'

require 'ruml/dot/model_diagram'

module Ruml::Transpiler
  class VisitorImpl < RumlBaseVisitor
    class << self
      def with(diagram)
        visitor = new
        visitor.diagram(diagram)
        visitor
      end
    end

    def diagram(diagram)
      @diagram = diagram
    end

    def visitRuml(ctx)
      visitChildren(ctx)
      @diagram.build
    end

    def visitModule_def(ctx)
      @member = @diagram.add_shape(:module, ctx.IDENTIFIER.getText)
      visit(ctx.body)
    end

    def visitClass_def(ctx)
      @member = @diagram.add_shape(:class, visit(ctx.class_name))
      @member.super_class(visit(ctx.super_class_name)) if ctx.super_class_name
      visit(ctx.body)
    end

    def visitClass_name(ctx)
      ctx.IDENTIFIER.getText
    end

    def visitSuper_class_name(ctx)
      ctx.IDENTIFIER.getText
    end

    def visitInclude_def(ctx)
      @member.module(:include, ctx.IDENTIFIER.getText)
    end

    def visitExtend_def(ctx)
      @member.module(:extend, ctx.IDENTIFIER.getText)
    end

    def visitAttr_reader(ctx)
      ctx.SYMBOL.each { |node| @member.attribute(node.getText, :r) }
    end

    def visitAttr_writter(ctx)
      ctx.SYMBOL.each { |node| @member.attribute(node.getText, :w) }
    end

    def visitAttr_accessor(ctx)
      ctx.SYMBOL.each { |node| @member.attribute(node.getText, :rw) }
    end

    def visitClass_method_def(ctx)
      name = visit(ctx.class_method_name)
      params = visit(ctx.params)
      @member.method(name, params, :class)
    end

    def visitClass_method_name(ctx)
      ctx.IDENTIFIER.getText
    end

    def visitInstance_method_def(ctx)
      name = visit(ctx.instance_method_name)
      params = visit(ctx.params)
      @member.method(name, params)
    end

    def visitParams(ctx)
      ctx.param.map { |node| visit(node) }
    end

    def visitInstance_method_name(ctx)
      ctx.IDENTIFIER.getText
    end

    def visitNormal_param(ctx)
      ctx.IDENTIFIER.getText
    end

    def visitKeyword_param(ctx)
      value = ctx.value ? " #{visit(ctx.value)}" : ''
      "#{ctx.KEYWORD_PARAM_NAME.getText}#{value}"
    end

    def visitDefault_param(ctx)
      "#{ctx.IDENTIFIER.getText} = #{visit(ctx.value)}"
    end

    def visitStringValue(ctx)
      ctx.STRING.getText
    end

    def visitSymbolValue(ctx)
      ctx.SYMBOL.getText
    end

    def visitNumberValue(ctx)
      ctx.NUMBER.getText
    end
  end
end

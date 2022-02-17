# Tags Example for the Proposals Module

## Create command extensions

Create the following class at
`app/commands/concerns/proposal_command_extensions.rb`:

```ruby
# frozen_string_literal: true

module ProposalCommandExtensions
  extend ActiveSupport::Concern

  include Decidim::Tags::TaggingsCommand

  included do
    if private_method_defined?(:create_proposal, true) && !private_method_defined?(:create_proposal_orig)
      alias_method :create_proposal_orig, :create_proposal
      private :create_proposal_orig
    end
    if private_method_defined?(:update_proposal) && !private_method_defined?(:update_proposal_orig)
      alias_method :update_proposal_orig, :update_proposal
      private :update_proposal_orig
    end
    if private_method_defined?(:update_draft) && !private_method_defined?(:update_draft_orig)
      alias_method :update_draft_orig, :update_draft
      private :update_draft_orig
    end

    private

    def create_proposal
      create_proposal_orig
      update_taggings(proposal, form)
    end

    def update_proposal
      update_proposal_orig
      update_taggings(proposal, form)
    end

    def update_draft
      update_draft_orig
      update_taggings(proposal, form)
    end
  end
end
```

## Apply the Extensions to Proposals Module Classes

Create the following to_prepare hook at `config/application.rb`:

```ruby
class Application < Rails::Application
  config.to_prepare do
    Decidim::Proposals::Proposal.include(Decidim::Tags::Taggable)
    Decidim::Proposals::ProposalForm.include(Decidim::Tags::TaggableForm)
    Decidim::Proposals::ProposalWizardCreateStepForm.include(Decidim::Tags::TaggableForm)
    Decidim::Proposals::Admin::ProposalForm.include(Decidim::Tags::TaggableForm)

    Decidim::Proposals::CreateProposal.include(ProposalCommandExtensions)
    Decidim::Proposals::UpdateProposal.include(ProposalCommandExtensions)
  end
end
```

## Customize the Views

### Add the Taggings Input to the Form

Copy `app/views/decidim/proposals/proposals/_edit_form_fields.html.erb` from the
proposals module to your local application within the same path. Add this change
there to the location where you would see the taggings input fit best (e.g.
under the body text field):

```erb
<%== cell("decidim/tags/form", form, label: t("activemodel.attributes.taggings.tags")) %>
```

### Add the Tags to the View

Copy `app/views/decidim/proposals/proposals/show.html.erb` from the proposals
module to your local application within the same path. Add this change there
to the location where you would see the taggings input fit best (e.g. under the
body text):

```erb
<%== cell("decidim/tags/tags", @proposal) %>
```

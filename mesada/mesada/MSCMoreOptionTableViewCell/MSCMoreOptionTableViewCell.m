//
//  MSCMoreOptionTableViewCell.m
//  MSCMoreOptionTableViewCell
//
//  Created by Manfred Scheiner (@scheinem) on 20.08.13.
//  Copyright (c) 2013 Manfred Scheiner (@scheinem). All rights reserved.
//

#import "MSCMoreOptionTableViewCell.h"
#import <objc/message.h>

@interface MSCMoreOptionTableViewCell ()

@property (nonatomic, strong) UIButton *optionButtonMail;
@property (nonatomic, strong) UIButton *optionButtonConfig;
@property (nonatomic, strong) UIButton *optionButtonEdit;
@property (nonatomic, strong) UIButton *optionButtonDelete;
@property (nonatomic, strong) UIView *borda1;
@property (nonatomic, strong) UIView *borda2;
@property (nonatomic, strong) UIScrollView *cellScrollView;

@end

@implementation MSCMoreOptionTableViewCell

////////////////////////////////////////////////////////////////////////
#pragma mark - Life Cycle
////////////////////////////////////////////////////////////////////////

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _optionButtonMail = nil;
        _optionButtonConfig = nil;
        _optionButtonEdit = nil;
        _optionButtonDelete = nil;
        _cellScrollView = nil;
        _borda1 = nil;
        _borda2 = nil;
        
        [self setupMoreOption];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _optionButtonMail = nil;
        _optionButtonConfig = nil;
        _optionButtonEdit = nil;
        _optionButtonDelete = nil;
        _cellScrollView = nil;
        _borda1 = nil;
        _borda2 = nil;
        
        [self setupMoreOption];
    }
    return self;
}

- (void)dealloc {
    [self.cellScrollView.layer removeObserver:self forKeyPath:@"sublayers" context:nil];
}

////////////////////////////////////////////////////////////////////////
#pragma mark -  IOS 8
////////////////////////////////////////////////////////////////////////


- (void)insertSubview:(UIView *)view atIndex:(NSInteger)index {
    NSString *className = NSStringFromClass(view.class);
    if ([className hasPrefix:@"UI"] && [className hasSuffix:@"ConfirmationView"]) {
        /*
         * Only provide 'MSCMoreOptionTableViewCell' functionality when iOS 8's new
         * 'tableView:editActionsForRowAtIndexPath:' isn't used.
         *
         * For a sample implementation of this new functionality take a look at:
         * https://gist.github.com/scheinem/e36835db07486e9f7e64
         */
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if (![[self tableView].delegate respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
#pragma clang diagnostic pop
            /*
             * Get '_UITableViewCellActionButton' instance which represents the "delete"
             * button. Therefore the parallel usage of 'tableView:editActionsForRowAtIndexPath:'
             * isn't possible because the "delete" button can't be distinguished from the other
             * action buttons.
             */
            __block UIButton *button = nil;
            [view.subviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
                if ([NSStringFromClass(subview.class) hasPrefix:@"_"] &&
                    [NSStringFromClass(subview.class) hasSuffix:@"Button"]) {
                    button = (UIButton *)subview;
                    *stop = YES;
//                    button.frame = CGRectMake(0.0, 0.0, 0.0, 0.0);
//                    [button removeFromSuperview];
//                    button = nil;
                }
            }];

            [self configureMoreOptionButtonForDeleteConfirmationView:view
                                        withDeleteConfirmationButton:button];

                            button.frame = CGRectMake(0.0, 0.0, 0.0, 0.0);
                            [button removeFromSuperview];
                      //      button = nil;
            /* aqui */
            CGRect rect = view.frame;
            // calcular manualmente a largura
            rect.size.width = 200;
            rect.origin.x = view.superview.bounds.size.width - rect.size.width;
            view.frame = rect;
            
   /*         UIButton *deleteConfirmationButton = [self deleteButtonFromDeleteConfirmationView:view];
            if (deleteConfirmationButton){
                [deleteConfirmationButton removeFromSuperview];
            }
    */
            float larguraPadrao = 45.0;
            float tamanhoDaView = view.bounds.size.width;
            // largura da view nunca é utilizada
            float larguraDaBorda = 10.0;
            float altura = view.bounds.size.height;
            float origem = tamanhoDaView;
            
            origem = origem - larguraDaBorda;
            
            self.borda1 = [[UIView alloc] initWithFrame: CGRectMake ( origem, 0.0, larguraDaBorda, altura)];
            self.borda1.backgroundColor = [UIColor yellowColor];
            [view addSubview:self.borda1];
            
            
            origem = origem - larguraPadrao;
            
            self.optionButtonDelete = [[UIButton alloc] initWithFrame:CGRectZero];
            [self ajustaBotao:self.optionButtonDelete imagem: @"trash" frame:CGRectMake(origem, 0.0, larguraPadrao, altura)];
            [view addSubview:self.optionButtonDelete];
            [self.optionButtonDelete addTarget:self action:@selector(deleteOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            origem = origem - larguraPadrao;
            
            self.optionButtonEdit = [[UIButton alloc] initWithFrame:CGRectZero];
            [self ajustaBotao:self.optionButtonEdit imagem:@"edituser" frame:CGRectMake(origem, 0.0, larguraPadrao, altura)];
            [view addSubview:self.optionButtonEdit];
            [self.optionButtonEdit addTarget:self action:@selector(editOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            origem = origem - larguraPadrao;
            
            self.optionButtonConfig = [[UIButton alloc] initWithFrame:CGRectZero];
            [self ajustaBotao:self.optionButtonConfig imagem:@"settings" frame:CGRectMake(origem, 0.0, larguraPadrao, altura)];
            [view addSubview:self.optionButtonConfig];
            [self.optionButtonConfig addTarget:self action:@selector(configOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            origem = origem - larguraPadrao;
            
            self.optionButtonMail = [[UIButton alloc] initWithFrame:CGRectZero];
            [self ajustaBotao:self.optionButtonMail imagem:@"message" frame:CGRectMake(origem, 0.0, larguraPadrao, altura)];
            [view addSubview:self.optionButtonMail];
            [self.optionButtonMail addTarget:self action:@selector(mailOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            
            
            origem = origem - larguraDaBorda;
            
            self.borda2 = [[UIView alloc] initWithFrame: CGRectMake ( origem, 0.0, larguraDaBorda, altura)];
            self.borda2.backgroundColor = [UIColor yellowColor];
            [view addSubview:self.borda2];
            
            
            
            
            /*
             * A little bit of obfuscation for the non public initializer 'initWithFrame:actionButtons:contentSize:'.
             * The initializer must be called because the property 'contentSize' isn't accessiable through a setter.
             */
            NSString *initializerSelectorName = [NSString stringWithFormat:@"%@%@:%@:", @"initWithFrame:actionButt", @"ons", @"contentSize"];
            ((void (*)(id, SEL, CGRect, NSArray *, CGSize))objc_msgSend)(view, NSSelectorFromString(initializerSelectorName), view.frame, @[button], CGSizeMake(button.frame.size.width + 200, button.frame.size.height));
        }
    }
    
    [super insertSubview:view atIndex:index];
}

- (void)configureMoreOptionButtonForDeleteConfirmationView:(UIView *)deleteConfirmationView
                              withDeleteConfirmationButton:(UIButton *)deleteConfirmationButton {
    
    /*
     * 'Normalize' 'UITableViewCellDeleteConfirmationView's' title text implementation, because
     * under iOS 7 UIKit itself doesn't show the text using it's 'UIButtonLabel's' setTitle: but
     * using a seperate 'UILabel'.
     *
     * WHY Apple, WHY?
     *
     */
    [deleteConfirmationButton.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger idx, BOOL *stop) {
        if ([view class] == [UILabel class]) {
            UILabel *titleLabel = (UILabel *)view;
  //          NSString *deleteConfirmationButtonTitle = titleLabel.text;
            [titleLabel removeFromSuperview];
            titleLabel = nil;
            
//            [deleteConfirmationButton setTitle:deleteConfirmationButtonTitle forState:UIControlStateNormal];
            
            // Needed because otherwise the sizing algorithm wouldn't work for iOS 7
            deleteConfirmationButton.autoresizingMask = UIViewAutoresizingNone;
            
            *stop = YES;
        }
    }];
    // Set default titleEdgeInsets on 'delete' button
    [deleteConfirmationButton setTitleEdgeInsets:UIEdgeInsetsMake(0.f, 0.f, 0.f, 0.f)];
    // Set clipsToBounds to YES on 'delete' button is necessary because otherwise it wouldn't
    // be possible to hide it settings it's frame's width to zero (the title would appear anyway).
    deleteConfirmationButton.clipsToBounds = YES;
    
    // Need to get the delegate as strong variable because it's a weak property


    // If created add the 'more' button to the cell's view hierarchy
//    if (self.moreOptionButton) {
//        [deleteConfirmationView addSubview:self.moreOptionButton];
//    }
}

- (void)willRemoveSubview:(UIView *)subview {
    [super willRemoveSubview:subview];
    
    // Set the 'more' button to nil if the 'swipe to delete' container view won't be visible anymore.
    NSString *className = NSStringFromClass(subview.class);
    if ([className hasPrefix:@"UI"] && [className hasSuffix:@"ConfirmationView"]) {
        self.optionButtonConfig = nil;
        self.optionButtonDelete = nil;
        self.optionButtonEdit = nil;
        self.optionButtonMail = nil;
        self.borda1 = nil;
        self.borda2 = nil;
    }
}



////////////////////////////////////////////////////////////////////////
#pragma mark - NSObject(NSKeyValueObserving) IOS 7
////////////////////////////////////////////////////////////////////////

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"sublayers"]) {
        /* 
         * Using '==' instead of 'isEqual:' to compare the layer's delegate and the cell's contentScrollView
         * because it must be the same instance and not an equal one.
         */
        if ([object isKindOfClass:[CALayer class]] && ((CALayer *)object).delegate == self.cellScrollView) {
            BOOL moreOptionDelteButtonVisiblePrior = (self.optionButtonEdit != nil);
            BOOL swipeToDeleteControlVisible = NO;
            for (CALayer *layer in [(CALayer *)object sublayers]) {
                /*
                 * Check if the view is the "swipe to delete" container view.
                 */
                NSString *name = NSStringFromClass([layer.delegate class]);
                if ([name hasPrefix:@"UI"] && [name hasSuffix:@"ConfirmationView"]) {
                    if (self.optionButtonEdit) {
                        swipeToDeleteControlVisible = YES;
                    }
                    else {
                        UIView *deleteConfirmationView = layer.delegate;

                        CGRect rect = deleteConfirmationView.frame;
                        // calcular manualmente a largura
                        rect.size.width = 200;
                        rect.origin.x = deleteConfirmationView.superview.bounds.size.width - rect.size.width;
                        deleteConfirmationView.frame = rect;

                        UIButton *deleteConfirmationButton = [self deleteButtonFromDeleteConfirmationView:deleteConfirmationView];
                        if (deleteConfirmationButton){
                            [self configureMoreOptionButtonForDeleteConfirmationView:deleteConfirmationView
                                                        withDeleteConfirmationButton:deleteConfirmationButton];
                            [deleteConfirmationButton removeFromSuperview];
                        }
                        
                        float larguraPadrao = 45.0;
                        float tamanhoDaView = deleteConfirmationView.bounds.size.width;
                        // largura da view nunca é utilizada
                        float larguraDaBorda = 10.0;
                        float altura = deleteConfirmationView.bounds.size.height;
                        float origem = tamanhoDaView;
                        
                        origem = origem - larguraDaBorda;
                        
                        self.borda1 = [[UIView alloc] initWithFrame: CGRectMake ( origem, 0.0, larguraDaBorda, altura)];
                        self.borda1.backgroundColor = [UIColor yellowColor];
                        [deleteConfirmationView addSubview:self.borda1];


                        origem = origem - larguraPadrao;
                        
                        self.optionButtonDelete = [[UIButton alloc] initWithFrame:CGRectZero];
                        [self ajustaBotao:self.optionButtonDelete imagem: @"trash" frame:CGRectMake(origem, 0.0, larguraPadrao, altura)];
                        [deleteConfirmationView addSubview:self.optionButtonDelete];
                        [self.optionButtonDelete addTarget:self action:@selector(deleteOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        
                        origem = origem - larguraPadrao;
                        
                        self.optionButtonEdit = [[UIButton alloc] initWithFrame:CGRectZero];
                        [self ajustaBotao:self.optionButtonEdit imagem:@"edituser" frame:CGRectMake(origem, 0.0, larguraPadrao, altura)];
                        [deleteConfirmationView addSubview:self.optionButtonEdit];
                        [self.optionButtonEdit addTarget:self action:@selector(editOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

                        origem = origem - larguraPadrao;
                        
                        self.optionButtonConfig = [[UIButton alloc] initWithFrame:CGRectZero];
                        [self ajustaBotao:self.optionButtonConfig imagem:@"settings" frame:CGRectMake(origem, 0.0, larguraPadrao, altura)];
                        [deleteConfirmationView addSubview:self.optionButtonConfig];
                        [self.optionButtonConfig addTarget:self action:@selector(configOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        
                        origem = origem - larguraPadrao;
                        
                        self.optionButtonMail = [[UIButton alloc] initWithFrame:CGRectZero];
                        [self ajustaBotao:self.optionButtonMail imagem:@"message" frame:CGRectMake(origem, 0.0, larguraPadrao, altura)];
                        [deleteConfirmationView addSubview:self.optionButtonMail];
                        [self.optionButtonMail addTarget:self action:@selector(mailOptionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
                        
                        
                        origem = origem - larguraDaBorda;
                        
                        self.borda2 = [[UIView alloc] initWithFrame: CGRectMake ( origem, 0.0, larguraDaBorda, altura)];
                        self.borda2.backgroundColor = [UIColor yellowColor];
                        [deleteConfirmationView addSubview:self.borda2];
                    }
                }
            }
            if (moreOptionDelteButtonVisiblePrior && !swipeToDeleteControlVisible) {
                self.optionButtonConfig = nil;
                self.optionButtonDelete = nil;
                self.optionButtonEdit = nil;
                self.optionButtonMail = nil;
                self.borda1 = nil;
                self.borda2 = nil;
            }
        }
    }
}

////////////////////////////////////////////////////////////////////////
#pragma mark - private methods
////////////////////////////////////////////////////////////////////////

/*
 * Looks for a UIDeleteConfirmationButton in a given UIDeleteConfirmationView.
 * Returns nil if the button could not be found.
 */
- (UIButton *)deleteButtonFromDeleteConfirmationView:(UIView *)deleteConfirmationView {
    
    for (UIButton *deleteConfirmationButton in deleteConfirmationView.subviews) {
        NSString *name = NSStringFromClass([deleteConfirmationButton class]);
        if ([name hasPrefix:@"UI"] && [name rangeOfString:@"Delete"].length > 0 && [name hasSuffix:@"Button"]) {
            return deleteConfirmationButton;
        }
    }
    return nil;
}

- (void)deleteOptionButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate tableView:[self tableView] deleteOptionButtonPressedInRowAtIndexPath:[[self tableView] indexPathForCell:self]];
    }
}

- (void)configOptionButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate tableView:[self tableView] configOptionButtonPressedInRowAtIndexPath:[[self tableView] indexPathForCell:self]];
    }
}

- (void)editOptionButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate tableView:[self tableView] editOptionButtonPressedInRowAtIndexPath:[[self tableView] indexPathForCell:self]];
    }
}

- (void)mailOptionButtonPressed:(id)sender {
    if (self.delegate) {
        [self.delegate tableView:[self tableView] mailOptionButtonPressedInRowAtIndexPath:[[self tableView] indexPathForCell:self]];
    }
}


- (UITableView *)tableView {
    UIView *tableView = self.superview;
    while(tableView) {
        if(![tableView isKindOfClass:[UITableView class]]) {
			tableView = tableView.superview;
		}
        else {
            return (UITableView *)tableView;
        }
	}
    return nil;
}


- (void)setupMoreOption {
    /*
     * Look for UITableViewCell's scrollView.
     * Any CALayer found here can only be generated by UITableViewCell's
     * 'initWithStyle:reuseIdentifier:', so there is no way adding custom
     * sublayers before. This means custom sublayers are no problem and
     * don't break MSCMoreOptionTableViewCell's functionality.
     */
    for (CALayer *layer in self.layer.sublayers) {
        if ([layer.delegate isKindOfClass:[UIScrollView class]]) {
            _cellScrollView = (UIScrollView *)layer.delegate;
            [_cellScrollView.layer addObserver:self forKeyPath:@"sublayers" options:NSKeyValueObservingOptionNew context:nil];
            break;
        }
    }
}

- (void)ajustaBotao:(UIButton *)botao imagem:(NSString *)imagem frame:(CGRect)frame
{
    [botao setImage:[UIImage imageNamed:imagem] forState:UIControlStateNormal];
    botao.frame = frame;
    botao.backgroundColor = [UIColor yellowColor];
}

@end

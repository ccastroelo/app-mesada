//
//  imSenhaVC.m
//  mesada
//
//  Created by claudio on 17/10/13.
//  Copyright (c) 2013 ideiasmob. All rights reserved.
//

#import "imSenhaVC.h"
#import "SFHFKeychainUtils.h"

@interface imSenhaVC ()

@end

@implementation imSenhaVC

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    
     NSError *error;
    id password = [SFHFKeychainUtils getPasswordForUsername:@"br.eti.claudiocastro.mesada" andServiceName:@"senha2" error:&error];
    self.situacaoSenha.text = NSLocalizedString(@"ATIVADA", @"Msg de senha ativada");
    self.botao.text = NSLocalizedString(@"Toque aqui para desativar sua senha", @"Toque aqui para desativar sua senha");
    if(!password){
        self.situacaoSenha.text = NSLocalizedString(@"DESATIVADA", @"Msg de senha desativada");
        self.botao.text = NSLocalizedString(@"Toque aqui para ativar uma senha", @"Msg para ativar a senha");
    }
    [super viewWillAppear:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

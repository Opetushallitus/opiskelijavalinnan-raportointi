#!/usr/bin/env node
import 'source-map-support/register';
import * as cdk from 'aws-cdk-lib';

import { BastionStack } from '../lib/bastion-stack';
import { getGenericStackProps } from '../lib/config';
import { DatabaseStack } from '../lib/database-stack';
import { NetworkStack } from '../lib/network-stack';
import { S3Stack } from '../lib/s3-stack';

const app = new cdk.App();
const environmentName = app.node.tryGetContext('environment') || process.env.ENVIRONMENT;
const props = getGenericStackProps(environmentName);

const networkStack = new NetworkStack(app, 'NetworkStack', props);
const bastionStack = new BastionStack(app, 'BastionStack', {
  publicHostedZone: networkStack.publicHostedZone,
  vpc: networkStack.vpc,
  ...props,
});
new DatabaseStack(app, 'DatabaseStack', {
  bastionSecurityGroup: bastionStack.bastionSecurityGroup,
  publicHostedZone: networkStack.publicHostedZone,
  vpc: networkStack.vpc,
  ...props,
});
new S3Stack(app, 'S3Stack', { ...props });

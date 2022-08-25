const Operator = require('@dot-i/k8s-operator').default;
const ResourceEventType = require('@dot-i/k8s-operator').ResourceEventType;
const ResourceMetaImple = require('@dot-i/k8s-operator').ResourceMetaImple;
//const OperatorLogger = require('@dot-i/k8s-operator').OperatorLogger;
//const Bob = require('akridex-discovery')
const colors = require('colors')

class DebugLogger {
    debug(message) {
        console.log(message.blue)
    }
    info(message) {
        console.log(message.purple)
    }
    warn(message) {
        console.log(message.yellow)
    }
    error(message) {
        console.log(message.red)
    }
}

class AkriDEXOperator extends Operator {
    constructor() {
        super(new DebugLogger())
        //super()

        // test kubeconfig
        //console.log(this.kubeConfig)
        //this.k8sApi.readNamespace('default').then(
        //    (response) => {
        //        console.log(`read works`)
        //        //console.log(response)
        //    },
        //    (err) => {
        //        return resolve('namespace read failed successfully')
        //    },
        //).catch((reason) => {
        //    return reject('\n\ncatch while waiting for k8s to die')
        //})
    }

    async init() {
        // First create CRD so user doesn't have to
        var group, versions, plural
        try {
            var {group, versions, plural} = await this.registerCustomResourceDefinition(`${__dirname}/MarketUnitCRDv1beta1.yaml`);
        } catch (err) {
            console.log('Error creating resource'.red)
            console.log(err)
        }

        console.log(group)
        console.log(versions)
        console.log(plural)

        await this.watchResource(group, versions[0].name, plural, async (e) => {
            try {
                console.log('got resource!')
                if (e.type === ResourceEventType.Added || e.type === ResourceEventType.Modified) {
                    console.log(e.type)
                    if (!await this.handleResourceFinalizer(e, `${plural}.${group}`, (ev) => this.resourceDeleted(ev))) {
                        await this.resourceModified(e);
                    }
                }
            } catch (err) {
                console.log('Error watching resource'.red)
                console.log(err)
                // Log here...
            }
        });
    }

    async resourceModified(e) {
        const object = e.object;
        const metadata = object.metadata;

        if (!object.status || object.status.observedGeneration !== metadata.generation) {
            // TODO: handle resource modification here
            console.log('resource modified')

            await this.setResourceStatus(e.meta, {
                observedGeneration: metadata.generation
            });
        }
    }

    async resourceDeleted(e) {
        // TODO: handle resource deletion here
        console.log('resource deleted')
    }
}


const o = new AkriDEXOperator()
o.start()

const exit = (reason) => {
    o.stop()
    process.exit(0)
};

process.on('SIGTERM', () => exit('SIGTERM'))
    .on('SIGINT', () => exit('SIGINT'))

